"""仮の音（BGM・効果音）を作る。

本番の音源（録音・作曲）が入るまでの仮素材。ここで作った音は
assets/audio/ に書き出され、差し替える時は同じファイル名で上書きすればよい。

    python3 tools/make_placeholder_audio.py

必要なもの: numpy
"""

import math
import pathlib
import wave

import numpy as np

OUT = pathlib.Path(__file__).resolve().parent.parent / "assets" / "audio"
SR = 22050
rng = np.random.default_rng(20260926)


def write(name: str, x: np.ndarray, sr: int = SR, level_db: float = -24.0) -> None:
    """音量を揃えて書き出す（RMS を level_db に合わせ、ピークは -1 dBFS に収める）。"""
    x = x - x.mean()
    rms = math.sqrt(float((x**2).mean())) + 1e-12
    x = x * (10 ** (level_db / 20) / rms)
    peak = float(np.abs(x).max())
    if peak > 0.89:
        x = x * (0.89 / peak)
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes((x * 32767).astype(np.int16).tobytes())
    print(f"{name}: {len(x) / sr:.1f}s")


def loop(x: np.ndarray, fade: float = 1.5, sr: int = SR) -> np.ndarray:
    """頭と尻を重ねて、継ぎ目のないループにする。"""
    n = int(fade * sr)
    head, body, tail = x[:n], x[n:-n], x[-n:]
    t = np.linspace(0, 1, n)
    mixed = tail * np.cos(t * math.pi / 2) + head * np.sin(t * math.pi / 2)
    return np.concatenate([body, mixed])


def onepole_lowpass(x: np.ndarray, cutoff: float, sr: int = SR) -> np.ndarray:
    a = math.exp(-2 * math.pi * cutoff / sr)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def brown(n: int) -> np.ndarray:
    b = np.cumsum(rng.standard_normal(n))
    b -= onepole_lowpass(b, 2.0)
    return b / (np.abs(b).max() + 1e-9)


def piano(freq: float, dur: float, sr: int = SR, vel: float = 1.0) -> np.ndarray:
    """やわらかいピアノ風の音（倍音＋減衰＋少しの揺れ）。"""
    t = np.arange(int(dur * sr)) / sr
    env = np.exp(-t * 2.2) * (1 - np.exp(-t * 90))
    tone = sum(
        (0.6 ** k) * np.sin(2 * math.pi * freq * (k + 1) * t * (1 + 0.0004 * k) + rng.uniform(0, 6))
        for k in range(5)
    )
    return vel * env * tone / 2.0


def note(name: str) -> float:
    names = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    base = names[name[0]]
    i = 1
    if name[i] in "#b":
        base += 1 if name[i] == "#" else -1
        i += 1
    octave = int(name[i:])
    return 440.0 * 2 ** ((base + (octave - 4) * 12) / 12)


def add(buf: np.ndarray, x: np.ndarray, at: float, sr: int = SR) -> None:
    s = int(at * sr)
    e = min(len(buf), s + len(x))
    buf[s:e] += x[: e - s]


def room_tone() -> np.ndarray:
    """店の物音：低い空調、時計、たまにカップの音。"""
    dur = 26.0
    n = int(dur * SR)
    x = brown(n) * 0.10
    t = np.arange(n) / SR
    for s in np.arange(0.5, dur, 1.0):  # 振り子時計
        tick = np.exp(-np.arange(int(0.03 * SR)) / (0.004 * SR)) * rng.standard_normal(int(0.03 * SR))
        add(x, onepole_lowpass(tick, 2500) * 0.12, s)
    for s in (4.3, 11.8, 19.2):  # カップとソーサー
        k = np.arange(int(0.4 * SR)) / SR
        clink = sum(np.sin(2 * math.pi * f * k) * np.exp(-k * d) for f, d in ((2630, 18), (4110, 25), (5620, 32)))
        add(x, clink * 0.05, s)
    x += 0.01 * np.sin(2 * math.pi * 55 * t)  # 冷蔵庫
    return loop(x)


def rain_piano() -> np.ndarray:
    """雨音とピアノ：遅いジャズの和音。"""
    dur = 34.0
    n = int(dur * SR)
    rain = onepole_lowpass(rng.standard_normal(n), 3200) * 0.12
    rain += (rng.random(n) < 0.0009) * rng.uniform(0.2, 0.6, n) * 0.4  # 雨粒
    x = rain
    chords = [
        ["D3", "F3", "A3", "C4", "E4"],
        ["G2", "F3", "B3", "E4", "A4"],
        ["C3", "E3", "G3", "B3", "D4"],
        ["A2", "G3", "C#4", "F4", "Bb4"],
    ]
    beat = 2.0
    for bar in range(4):
        for i, nm in enumerate(chords[bar]):
            add(x, piano(note(nm), 5.0, vel=0.20), bar * beat * 4 + i * 0.22)
        melody = ["A4", "F4", "E4", "D4"] if bar % 2 == 0 else ["G4", "E4", "C4", "B3"]
        for j, nm in enumerate(melody):
            add(x, piano(note(nm), 3.0, vel=0.16), bar * beat * 4 + 2.0 + j * 1.3)
    return loop(x, 2.0)


def midnight_radio() -> np.ndarray:
    """深夜ラジオ：ノイズの向こうの、小さな音楽。"""
    sr = 16000
    dur = 28.0
    n = int(dur * sr)
    t = np.arange(n) / sr
    hiss = onepole_lowpass(rng.standard_normal(n), 3000, sr) * 0.08
    music = np.zeros(n)
    seq = ["E4", "G4", "A4", "G4", "E4", "D4", "C4", "D4"]
    for bar in range(7):
        for i, nm in enumerate(seq):
            if (bar + i) % 3 == 2:
                continue
            add(music, piano(note(nm), 1.6, sr, vel=0.25), bar * 4 + i * 0.5, sr)
        add(music, piano(note("C3") if bar % 2 == 0 else note("A2"), 3.5, sr, vel=0.3), bar * 4, sr)
    # ラジオっぽく：帯域を狭め、ゆっくり揺らす
    music = onepole_lowpass(music, 2200, sr) - onepole_lowpass(music, 300, sr)
    wobble = 1 + 0.15 * np.sin(2 * math.pi * 0.11 * t)
    x = music * wobble * 1.4 + hiss
    return loop(x, 1.5, sr)


def se_coin() -> np.ndarray:
    k = np.arange(int(0.5 * SR)) / SR
    a = sum(np.sin(2 * math.pi * f * k) * np.exp(-k * 9) for f in (1976, 2960))
    b = np.zeros_like(k)
    s = int(0.07 * SR)
    b[s:] = sum(np.sin(2 * math.pi * f * k[: len(k) - s]) * np.exp(-k[: len(k) - s] * 7) for f in (2637, 3951))
    return (a + b) * 0.25


def se_stamp() -> np.ndarray:
    k = np.arange(int(0.25 * SR)) / SR
    thump = np.sin(2 * math.pi * 110 * k * (1 - k)) * np.exp(-k * 28)
    grit = onepole_lowpass(rng.standard_normal(len(k)), 1200) * np.exp(-k * 60)
    return (thump * 0.8 + grit * 0.4) * 0.8


def se_gacha() -> np.ndarray:
    n = int(0.9 * SR)
    x = np.zeros(n)
    for i in range(14):
        at = 0.04 + i * 0.055 + rng.uniform(-0.01, 0.01)
        k = np.arange(int(0.05 * SR)) / SR
        click = onepole_lowpass(rng.standard_normal(len(k)), 4000) * np.exp(-k * 120)
        add(x, click * (0.4 + 0.3 * (i % 3 == 0)), at)
    return x * 0.8


def se_paper() -> np.ndarray:
    k = np.arange(int(0.35 * SR)) / SR
    env = np.sin(np.pi * k / k[-1]) ** 2
    return onepole_lowpass(rng.standard_normal(len(k)), 5000) * env * 0.25


if __name__ == "__main__":
    # BGM は小さめに（店の空気として鳴っている程度）。効果音は少し前に。
    write("bgm_room.wav", room_tone(), level_db=-30)
    write("bgm_rain_piano.wav", rain_piano(), level_db=-24)
    write("bgm_midnight_radio.wav", midnight_radio(), 16000, level_db=-26)
    write("se_coin.wav", se_coin(), level_db=-20)
    write("se_stamp.wav", se_stamp(), level_db=-20)
    write("se_gacha.wav", se_gacha(), level_db=-22)
    write("se_paper.wav", se_paper(), level_db=-24)
