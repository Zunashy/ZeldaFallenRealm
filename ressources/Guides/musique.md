# Guide pour créer une musique et la transformer en type 8bit (NES/GBC)

Dans ce petit tutoriel nous allons voir comment créer une musique à partir de rien.

# 1. Télécharger les 4 indispensables

Tout d'abord, commencez par télécharger ces 3 softs (+ java) qui seront nécéssaires pour mener à bien notre mission.

**Java** : [Java 8](https://alonsobertrand.fr/pub/java/jre-8u271-windows-x64.exe)

==> Ai-je besoin de présenter Java ? ;)

**Tuxguitar** : [TuxGuitar 1.5.4](https://alonsobertrand.fr/pub/tuxguitar-1.5.4-windows-x86-installer.exe)

==> TuxGuitar servira à composer la partition et d'exporter le rendu final au format MIDI


**GXSCC** : [GXS CC v236](https://alonsobertrand.fr/pub/gxscc.zip)

==> GSX CC va charger le fichier MIDI et le jouer en 8bit. Il permettra d'exporter ce rendu au format WAV

**Audacity** : [Audacity 2.4.2](https://alonsobertrand.fr/pub/audacity-win-2.4.2.exe)

==> Audacity va nous permettre de faire WAV==>OGG, format utilisé par solarus

# 2. Installation de Java

Installez le sinon Tuxguitar ne marchera pas.. Logiquement TuxGuitar embarque sa propre JVM (Java virtual machine) mais pour des raisons que j'ignore il refuse de s'installer sans.

Dans le doute => vous pouvez prendre soit Java 8 (1.8) ou Java 15 (pour les devs expérimentés)

# 3. Installation et configuration de TuxGuitar

## 3.1 Configuration
Il n'y a aucun pre-requis particulier pour installer TuxGuitar.

Si vous rencontrez ce message d'erreur : 

![erreur tuxguitar installation](https://alonsobertrand.fr/ZeldaFallen/tux1.png)

Faites abandonner et lancez l'installation en mode administrateur (clic droit sur le fichier.exe -> exécuter en tant qu'administrateur)
Ceci devrait résoudre le problème.

Une fois installé, lancez Tuxguitar et allez dans Outil -> Configuration -> Son et selectionnez ces séquenceurs et Validez : 
![sequenceur midi](https://alonsobertrand.fr/ZeldaFallen/tux2.png)


## 3.2 Composer

Sur l'écran de base de Tuxguitar, vous avez une piste créée automatiquement, avec une vue partition sur 1 ligne, la liste des pistes en bas et les differentes options purement 'musicales' sur le bloc de gauche(type de note, armure, tempo, etc etc).
Pour créer une note, placez vous sur la partition (et sur la ligne souhaitée) et utilisez le pavé numerique pour écrire un nombre.

Par defaut, la configuration de la partition est pour Guitare 6 cordes E-A-D-G-B-E en 4/4 (binaire), en Clé de sol, à la vitesse de 120bpm ; c'est à dire DO MAJEUR

Par defaut aussi, pour chaque piste, la partition s'affiche en 2 blocs : 
- Le bloc du bas correspond 'au manche' de la guitare, où vous aller ecrire vos notes à l'aide des nombres
- le bloc du haut correspond à ce qui s'affiche sur votre vraie partition.

Vous pouvez éditer que le bloc du bas avec votre pavé numerique.

![premieres notes](https://alonsobertrand.fr/ZeldaFallen/tux3.png)

Le nombre 0 sur chaque ligne (corde) correspond a la corde joué à vide.
Sur la capture ci-dessus, j'ai donc composé avec mes 0 la suite de notes suivante : 

*Mi La Re Sol Si Mi*

## 3.3 Changer d'instrument & d'accordage

Pour changer d'instrument, ou d'accordage (exemple : nous allons passer sur une guitare basse 5 cordes)
Doublez cliquer sur l'instrument (Stell String Guitar 1) a cet endroit : 

![instru](https://alonsobertrand.fr/ZeldaFallen/tux4.png)

Sur le petit menu qui va s'ouvrir, cliquez sur l'icone clé pour modifier l'accordage. Une autre pop-up va s'ouvrir et vous pourrez choisir plusieurs accordages

Selectionnez les 5cordes  B-E-A-D-G. Laissez le capodastre à 0 et faites Valider.

(B1-E2-A2-D3-G3 correspond a la hauteur 'octave'). 
 ==> Si vous mettez B2 ou B3 le Si sera 1 ou 2 octaves plus haut. Laissez par defaut ces valeurs. svp :D

![instru 5](https://alonsobertrand.fr/ZeldaFallen/tux5.png)

Maintenant que vous avez réglé votre instrument sur 5 cordes, il va falloir passer sur un son de guitare basse

Toujours sur la pop up principale, cliquez sur l'icone clé pour modifier l'instrument.
Le 1er instru dans la liste est le DrumKit, ignorez le et passez sur *Steel String Guitar 1*.
Profitez en pour le renommer "Basse" et choisissez l'instrument *Fingered Bass* pour avoir un vrai son de guitare basse joué avec les doigts !
Faites Valider, puis fermer.

![instru 6](https://alonsobertrand.fr/ZeldaFallen/tux6.png)

Vous voilà donc revenu dans la fenetre principale de partition. Celle-ci a été modifiée il n'y a plus 6 lignes mais 5. Votre son est bien celui d'une basse et vous êtes dans les graves.

Sachez que Tuxguitar peut gérer 10 pistes/instruments de manière simultanée.

Au dela de 10, les prochaines pistes calqueront l'instrument (et seulement l'instrument) suivant un schéma précis : 
Par exemple, la piste 11 utilisera l'instrument de la piste 1, et ainsi de suite. Je ne sais pas si c'est un bug ou une limitation vis à vis du MIDI. N'abusez donc pas des instruments :')

## 3.4 La piste DrumKit

Puisque TuxGuitar est un fork de GuitarPro (et donc pensé plutôt pour faire du Rock \m/ ), celui-ci embarque sa propre piste de percussions pour jouer le rôle de la batterie.
Chaque nombre (quelque soit la ligne) correspond a une type de percussion différent.

Voici un petit tableau repertoriant ce qui sera principalement utilisé : 

- Kick: 	      36, 35
- Snare:   	  40, 38
- Toms:    	  50, 48, 47, 45, 43, 41
- Ride cymbal:   51, 59
- Hi-hat: 	      42, 46, 44
- Crash cymbal:  49, 57
- Tambourine:    54
- Splash cymbal: 55
- Hand clap:     39

Il en existe bien d'autres ;  je vous laisse vous amuser avec votre pavé numérique. Si aucun son ne sort sur un nombre donné, c'est qu'aucun son na été défini.

Pour définir votre piste comme DrumKit. Double cliquez sur la piste en bas et choisissez l'instrument DrumKit

![instru 7](https://alonsobertrand.fr/ZeldaFallen/tux7.png)

## 3.5 Bonnes pratiques pour la partition
**À partir de là, il vous faut des connaissances musicales (solfège) pour pouvoir comprendre cette partie.** Sinon passez directement à la partie 3.6 


Nous avons vu que par defaut, la partition était du type Clé de Sol, Do majeur, 4/4, 120bpm et 6 cordes.
Si vous voulez à terme produire une vraie partition pour la retravailler ensuite avec MuseScore ou faire un export PDF, il va falloir mettre en pratique les vraies règles en musique ;).

## La Tonalité (armure)
Il existe beaucoup de tonalités. Chaque tonalité entraine des altérations de notes, ce qui se traduit par l'affichage sur la partition de dièses (♯), de bémols (♭) et de bécarres (♮).

- Le dièse (♯) permet de monter d'un demi-ton chromatique
- Le bémol (♭) permet de descendre d'un demi-ton chromatique
- le bécarre (♮) permet de remettre la note à sa hauteur naturelle (annule un dièse ou bémol d'une tonalité ou dans une même mesure)

On dit alors qu'il y a "X bémols à la clé" ou "X dièses à la clé".

Par exemple, si je suis en *Sol majeur* : il y a 1 note alterée qui est le Fa ; il y a donc *1 dièse la clé* et mon armure ressemble à ca : 

![instru 8](https://alonsobertrand.fr/ZeldaFallen/tux8.png)

Impact sur votre partition : En *Sol majeur*, lorsque vous rencontrerez un Fa, celui-ci sera par defaut un Fa♯.
Il sera donc inutile (interdit) d'indiquer le ♯ sur votre note sur la partition, puisque le ♯ est indiqué avec la clé et le tempo (cf screen ci-dessus).

Si vous voulez ne jouer un Fa mais pas un Fa♯ (donc retirer ponctuellement l'altération), on utilise un autre caractère qui s'appèle le bécarre (♮).

Pour modifier l'armure, allez dans Composition -> Armure et choisissez le nombre d'alterations (dièses ou bémols)

![instru 9](https://alonsobertrand.fr/ZeldaFallen/tux9.png)

## La clé
Dans une partition, la Clé permet de définir la hauteur des notes.

On en retiendra principalement 2 : 

- La clé de Sol : pour les aigus
- La clé de Fa : pour les graves

La guitare basse devra par exemple logiquement avoir une clé de Fa, tandis qu'une guitare sera en clé de sol. Cependant il est tout à fait possible de procéder à des changements de clés de manière ponctuelle.

Pour modifier la clé, allez dans Composition -> Clé et choisissez puis faites Valider

![instru 10](https://alonsobertrand.fr/ZeldaFallen/tux10.png)

## La pulsation et le chiffrage
La pulsation un battement régulier (comme un tic tac d'horloge), qui va servir à définir la vitesse (tempo) et donc à rythmer !

La vitesse (tempo) est définie par la valeur de la note. 

Par exemple : Par defaut sur TuxGuitar, le tempo est de 120 bpm (battements par minute) à la noire (note qui vaut 1 battement/pulsation). 
Plus vous montez la valeur, plus la pulsation sera rapide, et inversement. 

Pour modifier le Tempo, allez sur Composition -> Tempo

![instru 11](https://alonsobertrand.fr/ZeldaFallen/tux11.png)

Il existe des termes italiens qui correspondent à des fourchettes définies de tempo, voici quelques exemples: 

- Largo 	= 40-60 bpm
- Larghetto 	= 60-66 bpm
- Adagio 	= 66-76 bpm
- Andante 	= 76-108 bpm
- Moderato 	= 108-120 bpm
- Allegro 	= 120-160 bpm
- Presto 	= 168-200 bpm
- Prestissimo = 200-208 bpm 

La pulsation peut être subdivisée en 2 groupes : 
- Binaire (multiple de 2 : 2, 4, 8, etc)
- Ternaire (multiple de 3 : 3, 6, 9 etc)

Pour modéliser du binaire ; tapez du pied ou une pulsation et dites a voix haute "1 2", "1 2",  "1 2" où le 1 doit être prononcé lorsque vous tapez du pied.

Même exercioce pour le ternaire, sauf que vous allez prononcer  "1 2 3" "1 2 3" où le 1 doit être prononcé lorsque vous tapez du pied. Si vous avez gardé la même pulsation, le "1 2 3" doit etre prononcé plus rapidement que le "1 2".

Ceci est utilisé pour rythmer votre musique, et ceci est également défini sur la partition :

![instru 12](https://alonsobertrand.fr/ZeldaFallen/tux12.png)

Voici comment comprendre le 4/4 (binaire) : 
- Le numerateur indique le nombre de temps (ici, 4 temps)
- Le dénominateur indique l'unité de temps. ici, 4 correspond à une noire, 2 à une blanche, 1 à une ronde.
- ==> Notre mesure dure 4 temps et est mesurée par des noires

Si vous voulez faire une mesure plus courte (exemple une mesure binaire qui dure 3 pulsation), elle sera écrite comme ceci: 3/4

Pour le ternaire, c'est exactement pareil sauf qu'on travaille avec des multiples de 3 sur la ligne des numerateurs et on utilise 8 (croche) pour unité de temps pour le dénominateur.

Pour modifier le chiffrage allez sur Composition --> Chiffrage

![instru 13](https://alonsobertrand.fr/ZeldaFallen/tux13.png)

## 3.6 Sauvegarder et exporter mon travail

- Pour sauvegarder votre travail au format tuxguitar, faites simplement Fichier --> Enregistrez sous.. et enregistrez votre fichier au format par defaut <file.tg>

- Pour exporter votre rendu au format MIDI, faites fichier --> exporter -> Exporter midi (laissez transpose à 0) puis enregistrez votre fichier au format <file.mid>


# 4. Utilisation de GSX CC
Ce petit utilitaire tout mignon tout léger et ne nécessitant aucune installation va nous servir à 2 choses : 
- lire votre fichier midi comme si vous etiez sur une NES (ou gamleboy)
- exporter le rendu au format brut WAV

Faites une extraction de l'archive Zip et aller dans le dossier crééer suite à l'extraction.
Voici le contenu du dossier

Démarrez simplement gsxcc.exe

![gsx 1](https://alonsobertrand.fr/ZeldaFallen/gsx1.png)

Pour lire votre fichier Midi dans ce logiciel.. Faites simplement un Drag & Drop (glisser > déposer) du fichier midi dans la fenetre.
Le programme va alors lire automatiquement le fichier au format 8bit <3

Si le rendu 8bit vous satisfait pleinement, alors Cliquez sur l'icone sous *Authoring*. Confirmez avec OK
Une fois qu'il a fini, le fichier WAV est créé dans le repertoire d'où provient votre Fichier MIDI.

![gsx 2](https://alonsobertrand.fr/ZeldaFallen/gsx2.png)

YAY ! tout fonctionne à merveille :3

![gsx 3](https://alonsobertrand.fr/ZeldaFallen/gsx3.png)


# 5. Installation & Utilisation d'Audacity

Dernière étape : obtenir le format OGG

**Installation** : Installez bêtement.. suivant suivant suivant OK

**Utilisation** : 
- Ouvrez Audacity, et faites Fichier -> Importer -> Audio  et charger votre fichier WAV
Le spectre dit analogique va s'afficher sur tout votre écran. 
Faites Ctrl + A et faites 'Effets' -> 'Amplification' et laissez les valeurs proposées et faites Valider

![auda 1](https://alonsobertrand.fr/ZeldaFallen/auda1.png)

Ceci va permettre d'avoir un même volume sonore entre nos fichiers sonores. Très important pour avoir qqch d'homogène !

Maintenant, exportons notre fichier au format OGG

Faites Fichier -> Exporter -> Exporter en OGG

![auda 2](https://alonsobertrand.fr/ZeldaFallen/auda2.png)

Mettez la qualité à 5 (pour du 8bit pas besoin de consommer plus de bande passante). et faites enregsitrer.

Audacity va vous proposer de rentrer des Tags ID3 tels que Auteur, Album, Année, Titre.. Vous pouvez tout laisser vide et faire simplement Valider.

Et voilà votre fichier OGG prêt a être utilisé, entendu INGAME ! <3

# 6. Utiliser une manque de sons MIDI de meilleure qualité et la lire avec VLC <3

TuxGuitar embarque sa propre banque de sons MIDI qui est de bien meilleure qualité comparé à celle fournie par Windows et qui n'a pas évolué depuis + de 20ans.

Je vous propose donc de passer aux choses sérieuses en téléchargeant cette banque de sons MIDI : [MagicSFver2.sf2](https://alonsobertrand.fr/ZeldaFallen/MagicSFver2.sf2). Si cette banque de son n'est pas dans les soundfonts de TuxGuitar ( *C:\Program Files (x86)\tuxguitar-1.5.4\share\soundfont* ), profitez-en pour faire un petit copier/coller qui va bien !


Si vous n'avez pas [VLC](https://download.videolan.org/pub/videolan/vlc/last/win64/vlc-3.0.11-win64.exe), téléchargez le et installez-le.

Une fois VLC installé, nous allons lui permettre de lire les fichiers MIDI (extension .mid)

dans VLC allez dans **Outils** -> **Préférences**
et cochez en bas à droite seletionner **Afficher les paramètres : tous**

Puis naviguez dans Entrée / Codecs -> Codecs audio -> Fluidsynth
Faites Parcourir et chargez votre fichier **MagicSFver2.sf2**. Laissez les autres paramètres par defaut et faites Enregistrer.


![vlc 1](https://alonsobertrand.fr/ZeldaFallen/vlc1.png)

Vous pouvez maintenant lire des fichier **MIDI** avec **VLC** et le rendu est beaucoup plus propre <3