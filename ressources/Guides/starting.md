# Projet Fallen Realm : guide de départ

Ce guide expliquera coment démarrer avec le projet : comment télécharger le jeu et le modifier.

## Logiciels utilisés
Premièrement, il vous faudra certains logiciels (pas de gros trucs, même avec une connexion faible tout ça reste rapide à télécharger a priori).

### Git
Git est un gestionnaire de fichiers, qui permet globalement à plusieurs personnes de travailler sur les mêmes fichiers sans avoir à gérer la synchronosation soi même. D'un point de vue pratique, il vous servira surtout à télécharger le projet dans son état actuel et à mettre en ligne vos modifications.

Pour l'obtenir :

- téléchargez l'installer git [ici](https://git-scm.com/downloads).
- dans la fenêtre d'installation : lorsqu'il vous demande de choisir un éditeur de texte, choissez Visual Studio Code, notepadd++ ou Atom si vous les avez, sinon choisissez Nano. Pour tout le reste, laissez l'option par défaut.
- Une fois l'installation terminée, vous pouvez lancer la console Git depuis l'explorateur windows, avec clic droit -> ouvrir Git Bash. Vous pouvez aussi lancer la version graphique, mais perso je sais pas comment ça marche donc faudra voir avec qqun d'autre.

### Solarus
Solarus est un moteur de jeu. Il va simplement lire des jeux ou "quests", et les faire fonctionner (il se charge de gérer les sprites, les musiques, les maps, et les scripts de toutes sortes, de ceux qui définissent le comportement des enemis à ceux des menus). Il possède également un éditeur, qui permet de gérer les fichiers de la quest, les maps, et d'autres ressources. Il est important de noter qu'une quest n'est qu'un dossier supposé contenir les bons fichiers.

Il est donc évidemment nécessaire d'avoir solarus pour pouvoir lancer le jeu, et il est très conseillé de l'avoir pour éditer le jeu, même si certaines ressources doivent être faites en modifiant simplement certains fichier (les images, les sons) avec d'autres logiciels adaptés.

[Télécharger Solarus](https://www.solarus-games.org/en/solarus/download)

### [Code] Un éditeur de texte, ou juste Solarus
Il est possible de coder directement dans solarus, mais l'éditeur proposé n'est pas terrible. Si vous avez un éditeur/IDE préféré (personnellement je trouve Visual Studio Code parfait pour ça mais Notepadd++ fait l'affaire), dans solarus allez dans "outils->options-> éditeur de texte, cochez éditeur externe et entrez la commande que Solarus doit éxécuter pour ouvrir un script (%f sera remplacé par le chemin du fichier, et %p par le chemin du dossier de la quest).

### [Graphismes] Un éditeur d'images
Dans solarus, les sprites ne sont pas *que* des images : un sprite solarus est en réalité constitué d'une multitude d'animations, qui possèdent chacune plusieurs variantes (directions). Solarus vous permet évidemment de créer ces sprites, nommer leurs animations, définir le délai entre chaque frame d'une animation (tout cela fera l'objet d'un autre guide), mais les images qui composent les différents animations ne sont pas éditables dans solarus : pour créer les visuels il vous faudra un bon éditeur d'image, de préférence adapté au pixel art. J'utilise personnellement GIMP, qui fait parfaitement l'affaire, mais photoshop est presque aussi adapté, et parfois Paint suffit. Dans tous les cas, utilisez le logiciel avec lequel vous êtes le plus à l'aise.

### [Sons] Un éditeur de son
Solarus ne gère rien par rapport aux musiques et aux bruitages : il se contente de savoir que les fichiers sons existent (au format ogg vorbis) et permettre de les jouer de différentes manières. Tout le travail sonore devra donc être réalisé dans un logiciel adapté (Personnellement j'utilise  et conseille BeepBox pour la création 8/16-bits et Reaper pour la retouche).

### [Mappeurs] Rien, solarus suffit
Les maps sont entièrement gérées par solarus. Voilà voilà.


## Commencer à modifier le projet

Une fois que vous avez les bons logiciels, il vous faut récupérer le jeu avec Git.  
Pour commencer il est important de comprendre que Git a toujours un "dossier courant" : quand vous lancerez la console Git depuis l'explorateur Windows (clic droit -> ouvrir git bash), c'est le dossier où vous étiez qui sera le dossier courant.  
Lancez donc la console dans le dossier où vous voulez mettre les fichiers du jeu et éxécutez la commande `git clone https://github.com/Zunashy/ZeldaFallenRealm.git`. Git devrait commencer à télécharger le jeu sous la forme d'un dossier nommé "ZeldaFallenRealm".  

Par la suite, le dossier courant de Git devra toujours être ce dossier : si vous venez de fairele git clone, allez dans le dossier que vous venez de télécharger avec `cd ZeldaFallenRealm`, sinon lancez simplement la console depuis ce dossier.

** Vous pouvez commencer à modifier les fichiers du jeu !**

### Opérations courante
Au cours du projet, vous devrez régulièrement faire deux choses : récupérer les modifications apportées par les autres et mettre les votres en ligne.

##### Mettre vos modifs en ligne
- Commencez par dire à git de vérifier si de nouveaux fichiers ont été ajoutés avec `git add *`
- Il faut maintenant "commit" vos modifications, c'est à dire faire en sorte que Git les prenne en compte, avec `git commit -a -m "un message expliquant vos modifs rapidement"`
- Enfin, envoyez vos modifs sur le dépôt en ligne avec `git push origin master`

En cas de message d'erreur : si le message d'erreur contient `hint: Updates were rejected because the remote contains work that you do not have locally`
récupérez les modifs (voir paragraphe suivant) puis réesayer de `push`, sinon, demandez simplement sur le serveur Discord.


##### Récupérer les modifs des autres
/!\ _Avant de récupérer le travail des autres, vous devez impérativement avoir `commit`, vous ne devez pas avoir modifié les fichiers sans avoir `commit` les modifs. Si vous voulez annuler vos modifs depuis le dernier commit, faites `git stash`_

- `git pull` récupère les modifs apportées par les autres depuis le dépôt en ligne.
- Git effectuera parfois un *merge* pour harmoniser deux modifications, et ouvrira un éditeur de texte en vous demandant d'écrire un message de merge. Mettez n'importe quoi (vraiment, on s'en fout, git tient à ce qu'il y ait quelque chose mais osef), sauvegardez et fermez l'éditeur.
- Si pour une quelconque raison git refuse de terminer le `pull` après ça, vous affiche un message d'erreur ... ne perdez pas de temps à chercher à comprendre, on entre dans la partie obscure de Git, demandez sur le serveur discord.

##### gpush
Si vous utilisez le git.sh (voir aide sur le serveur discord) du projet, la commande `gpush "message` est l'équivalent des commandes suivantes
```
git add *
git commit -a -m "message"
git pull origin master
git push origin master
```

## Autres Guides
- [Mapping](mapping.md)
- [Mapping avancé](mapping_advanced.md)
- [Sauvegarde](savegame.md)
- [Items](items.md)
- [Tilesets](tilesets.md)

### Guides à venir
- Sprites
- Map (API)
- Ennemis
