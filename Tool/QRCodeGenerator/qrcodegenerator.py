import qrcode
from PIL import Image, ImageDraw



# Extract dominant color (approximate WindChime app color)
dominant_color = (15, 18, 41)  # dark navy blue

# Generate QR code with custom color
qr_data = "https://ghostp13409.github.io/"  # Replace with your target URL
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_H,
    box_size=10,
    border=4,
)
qr.add_data(qr_data)
qr.make(fit=True)

# Create QR code image
qr_img = qr.make_image(fill_color="white", back_color=dominant_color).convert("RGBA")

# Apply rounded corners to better match app style
mask = Image.new('L', (1080, 1080), 0)
draw = ImageDraw.Draw(mask)
draw.rounded_rectangle([(0, 0), (1080, 1080)], radius=40, fill=255)
# qr_img.putalpha(mask)



# Save final output
output_path = "website.png"
qr_img.save(output_path)
output_path
