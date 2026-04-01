#!/usr/bin/env python3
"""Generate a countdown wallpaper for iPhone."""

from PIL import Image, ImageDraw, ImageFont
from datetime import datetime, date, timedelta
import math
import os
import sys

# Config
START_DATE = date(2026, 4, 1)
TOTAL_DAYS = 50
GRID_COLS = 5  # 5 columns, 10 rows for 50 days

# iPhone 15/16 Pro resolution
WIDTH = 1179
HEIGHT = 2556

# Colors
BG_COLOR = (10, 10, 10)
RED = (230, 57, 70)       # #E63946
OUTLINE = (51, 51, 51)    # #333
TEXT_WHITE = (255, 255, 255)

def generate_wallpaper(output_path=None):
    today = date.today()
    current_day = (today - START_DATE).days + 1
    current_day = max(0, min(current_day, TOTAL_DAYS + 1))
    
    end_date = START_DATE + timedelta(days=TOTAL_DAYS - 1)
    
    img = Image.new('RGB', (WIDTH, HEIGHT), BG_COLOR)
    draw = ImageDraw.Draw(img, 'RGBA')
    
    # Grid dimensions — same overall width as before (~952px)
    grid_rows = math.ceil(TOTAL_DAYS / GRID_COLS)
    square_size = 120
    gap = 10
    grid_width = GRID_COLS * square_size + (GRID_COLS - 1) * gap
    grid_height = grid_rows * square_size + (grid_rows - 1) * gap
    
    start_x = (WIDTH - grid_width) // 2
    
    # Grid only — no text header (lock screen widgets cover that area)
    start_y = (HEIGHT - grid_height) // 2 + 150
    
    # Draw grid
    for i in range(TOTAL_DAYS):
        row = i // GRID_COLS
        col = i % GRID_COLS
        day = i + 1
        
        x = start_x + col * (square_size + gap)
        y = start_y + row * (square_size + gap)
        
        if day < current_day:
            # Completed - solid red
            draw.rounded_rectangle([x, y, x + square_size, y + square_size], radius=8, fill=RED)
        elif day == current_day and current_day <= TOTAL_DAYS:
            # Today - red with glow effect
            glow_pad = 6
            draw.rounded_rectangle(
                [x - glow_pad, y - glow_pad, x + square_size + glow_pad, y + square_size + glow_pad],
                radius=12, fill=(230, 57, 70, 60)
            )
            draw.rounded_rectangle([x, y, x + square_size, y + square_size], radius=8, fill=RED)
        else:
            # Remaining - outline only
            draw.rounded_rectangle([x, y, x + square_size, y + square_size], radius=8, outline=OUTLINE, width=2)
        
        # Day number
        try:
            font = ImageFont.truetype("/System/Library/Fonts/SFCompact.ttf", 24)
        except:
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
            except:
                font = ImageFont.load_default()
        
        text = str(day)
        bbox = draw.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        tx = x + (square_size - tw) // 2
        ty = y + (square_size - th) // 2
        
        if day < current_day or day == current_day:
            draw.text((tx, ty), text, fill=(255, 255, 255, 220), font=font)
        else:
            draw.text((tx, ty), text, fill=(255, 255, 255, 60), font=font)
    
    if output_path is None:
        output_path = os.path.expanduser("~/.openclaw/workspace/countdown-wallpaper.png")
    
    img.save(output_path, "PNG", quality=95)
    print(f"✅ Wallpaper generated: {output_path}")
    print(f"   Day {current_day} of {TOTAL_DAYS} | Ends {end_date.strftime('%B %d, %Y')}")
    return output_path

if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else None
    generate_wallpaper(out)
