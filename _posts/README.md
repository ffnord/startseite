# Blog 

Um einen neuen Beitrag zu erstellen brauchst du keine weitere Software. Das Blog kannst du **direkt im Browser hier auf Github bearbeiten**.


> Falls du zu ungeduldig bist, erstelle bitte gerne einfach ein **Issue** (oben unter "Issues") mit deinem Text für den neuen Blog Eintrag". Wir erstellen dann daraus einen Beitrag. Aber **bitte** erst einmal diese **kurze Anleitung zuende lesen**. Es ist viel einfacher als es zuerst erscheinen mag :)

1. Klicke einfach oben auf den Ordner `_posts` und führe dann folgende Schritte aus:

  - Logge dich in deinem Github Account ein (oder falls du einen eigenen Account ablehnst, benutze den Username: `ffki-blogger`, Passwort: `blogger77`)
  - Erstelle eine neue `.md` seite im ordner `_posts`, drücke dazu auf das Plus in der Überschrift:  
     `    / nord-blog / _posts / + `  
     ![new post](http://i.imgur.com/zTruxmS.png)  
     (beim ersten mal wird dabei automatisch eine Kopie dieses Projekts in deinem Github erzeugt, in dem du ab dann arbeitest). 
  - Die Benennung der Datei muss dabei mit dem Datum beginnen, gefolgt von einem rein informativen Teil der ignoriert wird, z.B. `2015-09-30-beschreibender-ignorierter-teil.md`
  - Der Inhalt der Datei muss anfangen mit den Zeilen:
 ```
 ---
 layout: post
 title: Hier der Titel deiner neuen Seite
 ---
 Hier Der Text für deinen neuen Blog Eintrag
 ```
  - Formatierungen können mit den Knöpfen über dem Eingabefeld erstellt werden
  - in dem Reiter "Preview changes" kannst du jederzeit überprüfen, wie dein Post aussehen würde.
  - optional: Bilder können in den ordner `images` hochgeladen werden, diese werden auf der Webseite unter `/images/blog/` verlinkt
  - optional: weitere Formatierungen findet man wenn man nach *"markdown cheat sheet"* googelt, z.B. https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

2. Wähle dann unten "Propose new file"
3. Wenn du fertig bist, erstelle einen "Pull Request" mit dem grünen Symbol, dadurch wird ein "Pull Request Issue" erstellt, in dem ein anderer Mitarbeiter des startseiten Projekts deine Änderungen noch einmal anschauen kann und dann freigeben.
