import cv2
import numpy as np

# Bilder laden
img1 = cv2.imread('bild1.jpg')
img2 = cv2.imread('bild2.jpg')

# Größe der Bilder ermitteln
h, w, _ = img1.shape

# Unterschiedsbild berechnen
diff = cv2.absdiff(img1, img2)

# Graustufenbild erzeugen
gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)

# Schwellenwert anwenden, um das Bild zu binarisieren
_, thresh = cv2.threshold(gray, 33, 255, cv2.THRESH_BINARY)

# Konturen extrahieren
contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# Nur Konturen mit einer Fläche von mindestens 100 Pixeln berücksichtigen
contours = [c for c in contours if cv2.contourArea(c) > 100]

# Größte Kontur ermitteln
max_contour = max(contours, key=cv2.contourArea)

# Maske erzeugen
mask = np.zeros((h, w), dtype=np.uint8)
cv2.drawContours(mask, [max_contour], 0, (255, 255, 255), -1)

# Maske auf das erste Bild anwenden
masked_img = cv2.bitwise_and(img1, img1, mask=mask)

# Bounding-Box um die größte Kontur ermitteln
x, y, bw, bh = cv2.boundingRect(max_contour)


# Bounding-Box um die größte Kontur ermitteln
x, y, bw, bh = cv2.boundingRect(max_contour)

# Rand um 4 Pixel verkleinern
x += 4
y += 4
bw -= 8
bh -= 8

# Ausgabe-Bild zuschneiden
cropped_img = masked_img[y:y+bh, x:x+bw]

# Ausgabe-Bild speichern
# cv2.imwrite('diff.jpg', cropped_img)

# Ausgabe-Bild mit transparentem Hintergrund speichern
temp = cv2.cvtColor(cropped_img, cv2.COLOR_BGR2GRAY)
_, alpha = cv2.threshold(temp, 0, 255, cv2.THRESH_BINARY)
b, g, r = cv2.split(cropped_img)
rgba = [b, g, r, alpha]
dst = cv2.merge(rgba, 4)
cv2.imwrite('diff.png', dst)

