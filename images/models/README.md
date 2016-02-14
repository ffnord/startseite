# Images created by Moorviper

These images are free images. source: https://github.com/Moorviper/Freifunk-Router-Anleitungen/wiki

downloaded and resized with

```
git clone https://github.com/Moorviper/Freifunk-Router-Anleitungen
cd Freifunk-Router-Anleitungen/
mkdir fronts
for i in *-*; do touch fronts/$i.jpg; cp $i/*front*.jpg fronts/$i.jpg; done
cd fronts/
for i in *.jpg; do
new="$(basename $i .jpg \
| sed -e 's/\.\(img\|vdi\|vmdk\)$//g' \
| sed -E 's/-v[0-9\.]+$//')_100x60.png"
#echo $new; done
touch $new
convert $i -resize 100x60 $new
done

convert  tp-link-tl-wr841n-nd-v11.jpg -resize 100x60 tp-link-tl-wr841n-nd_100x60.png
rm tp-link-tl-wr703n_100x60.png
touch tp-link-tl-wr703n_100x60.png
rm tp-link-tl-wr2543n-nd_100x60.png
touch tp-link-tl-wr2543n-nd_100x60.png

mkdir large
mv *jpg large/

mv fronts/* /var/www/freifunk/ffki-startseite/images/models/
```