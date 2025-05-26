import numpy as np
import soundfile as sf
import os
from scipy.signal import butter, lfilter

# === Parameters ===
sample_rate = 44100
duration = 0.7  # seconds
fade_duration = 0.2  # for soft attack and release
volume_scale = 0.05  # very soft volume

# === Helper Functions ===
def envelope(length, fade_time, sample_rate):
    fade_samples = int(fade_time * sample_rate)
    sustain_samples = length - 2 * fade_samples
    attack = np.linspace(0, 1, fade_samples)
    sustain = np.ones(sustain_samples)
    release = np.linspace(1, 0, fade_samples)
    return np.concatenate([attack, sustain, release])

def low_pass_filter(signal, cutoff=1000):
    b, a = butter(2, cutoff / (sample_rate / 2), btype='low')
    return lfilter(b, a, signal)

def generate_soft_tone(f_start, f_end=None, waveform='sine'):
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    if f_end and f_end != f_start:
        freqs = np.linspace(f_start, f_end, t.shape[0])
        phase = 2 * np.pi * np.cumsum(freqs) / sample_rate
    else:
        phase = 2 * np.pi * f_start * t

    if waveform == 'sine':
        tone = np.sin(phase)
    elif waveform == 'triangle':
        tone = 2 * np.abs(2 * (phase / (2 * np.pi) % 1) - 1) - 1
    else:
        tone = np.sin(phase)

    env = envelope(len(t), fade_duration, sample_rate)
    soft_tone = tone * env * volume_scale
    return low_pass_filter(soft_tone)

# === Output Directory ===
output_dir = "soft_meditation_sounds"
os.makedirs(output_dir, exist_ok=True)

# === Generate Sounds ===
sf.write(os.path.join(output_dir, "breath_in.wav"),
         generate_soft_tone(220, 280), sample_rate)

sf.write(os.path.join(output_dir, "hold.wav"),
         generate_soft_tone(250), sample_rate)

sf.write(os.path.join(output_dir, "breath_out.wav"),
         generate_soft_tone(280, 220), sample_rate)

# Rest - gentle triangle wave with slow tremolo
t = np.linspace(0, duration, int(sample_rate * duration), False)
tremolo = 0.8 + 0.2 * np.sin(2 * np.pi * 2 * t)  # slow 2Hz modulation
rest = generate_soft_tone(240, waveform='triangle') * tremolo
sf.write(os.path.join(output_dir, "rest.wav"), rest, sample_rate)

print("Meditation sounds saved to:", output_dir)
