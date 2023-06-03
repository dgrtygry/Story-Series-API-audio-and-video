import cv2
import numpy as np
import random
from pydub import AudioSegment
from pydub.generators import Sine
from moviepy.editor import *

# Function to generate a random shape
def generate_shape(frame, frame_num):
    shape_types = ["circle", "square", "triangle"]
    colors = [(255, 0, 0), (0, 255, 0), (0, 0, 255), (255, 255, 0), (255, 0, 255), (0, 255, 255)]

    max_shapes = frame_num + 1  # Increase the number of shapes with each frame
    max_intensity = frame_num + 1  # Increase the intensity with each frame

    for _ in range(max_shapes):
        shape_type = random.choice(shape_types)
        color = random.choice(colors[:max_intensity])
        size = random.randint(10, 60)
        x = random.randint(0, frame.shape[1] - size)
        y = random.randint(0, frame.shape[0] - size)

        if shape_type == "circle":
            cv2.circle(frame, (x, y), size // 2, color, -1)
        elif shape_type == "square":
            cv2.rectangle(frame, (x, y), (x + size, y + size), color, -1)
        elif shape_type == "triangle":
            points = np.array([[x + size // 2, y], [x, y + size], [x + size, y + size]], np.int32)
            cv2.fillPoly(frame, [points], color)

# Function to introduce pixel glitches in the frame
def glitch_frame(frame, frame_num):
    num_glitches = frame_num + 1  # Increase the number of glitches with each frame
    height, width, _ = frame.shape

    for _ in range(num_glitches):
        x = random.randint(0, width - 1)
        y = random.randint(0, height - 1)

        frame[y, x] = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))

# Function to generate random text
def generate_text(frame, frame_num):
    max_intensity = frame_num + 1  # Increase the intensity with each frame
    text = "01010101010100"
    font = cv2.FONT_HERSHEY_SIMPLEX
    scale = random.uniform(0.5, 2.0)
    thickness = random.randint(1, 3)
    color = random.choice([(0, 0, 0), (255, 255, 255)])

    (text_width, text_height), _ = cv2.getTextSize(text, font, scale, thickness)
    x = random.randint(0, frame.shape[1] - text_width)
    y = random.randint(0, frame.shape[0] - text_height)

    cv2.putText(frame, text, (x, y), font, scale, color, thickness, cv2.LINE_AA)

# Generate a unique seed for each session
seed = random.randint(0, 100000)
random.seed(seed)

# Video settings
width, height = 640, 480
fps = 30
duration = 60

# Generate a random number for the video name
random_number = random.randint(100000, 999999)
video_name = f"Story_Series_Episode_{random_number}.mp4"

fourcc = cv2.VideoWriter_fourcc(*"mp4v")
output = cv2.VideoWriter(video_name, fourcc, fps, (width, height))

# Generate video frames and audio
num_frames = fps * duration
audio = AudioSegment.empty()
for frame_num in range(num_frames):
    frame = np.zeros((height, width, 3), dtype=np.uint8)

    # Generate shapes
    generate_shape(frame, frame_num)

    # Generate text
    generate_text(frame, frame_num)

    # Add computer-generated noise
    noise = np.random.randint(0, 256, (height, width, 3), dtype=np.uint8)
    frame = cv2.add(frame, noise)

    # Add glitches
    glitch_frame(frame, frame_num)

    # Generate audio
    frequency = random.randint(100, 1000)
    duration = random.randint(100, 500)
    audio += Sine(frequency).to_audio_segment(duration=duration)

    output.write(frame)

    # Calculate and display the progress percentage
    progress = (frame_num + 1) / num_frames * 100
    print(f"Progress: {progress:.2f}%")

output.release()

# Export audio
audio_file = f"computer_audio_{random_number}.wav"
audio.export(audio_file, format="wav")

# Load video and audio
video = VideoFileClip(video_name)
audio = AudioFileClip(audio_file)

# Set audio for the video
video = video.set_audio(audio)

# Merge audio and video
merged_video = video.set_duration(duration)

# Export the final video
final_video_name = f"Story_Series_Episode_{random_number}_merged.mp4"
merged_video.write_videofile(final_video_name, codec="libx264")

print("Video generation complete. Seed:", seed)
print("Final video name:", final_video_name)
