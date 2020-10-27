# Sauvegarde
Ce qu'on entend par "sauvegarde", dans Solarus, est l'ensemble des données qui sont conservées quand Link change de map, et surtout quand le jeu est fermé.  

Ces données sont conservées sous la forme de **variables de sauvegarde**.   
Chaque variable est constituée d'une clé et d'une valeur, c'est à dire une valeur à laquelle on a donné un nom (clé).  
La valeur peut être : 
- un texte (chaîne de caractères)
- un nombre entier
- un booléen (soit `true` (vrai), soit `false` (faux))


```
Exemples :
- La vie actuelle de Link est stockée dans la variable nommée "current_life". Sa valeur est le nombre de HP (quarts de coeurs) restants de Link.
- La nom que le joueur à choisi est stocké dans la variable "name"
- L'état de la plume de roc (c'est à dire, si le joueur possède ou non la plume de roc) est stocké dans la variable "possesion_feather". Sa valeur est "true" si Link possède la plume. S'il ne la possède pas, la variable n'existe pas (ou a pour valeur "false", dans certains cas rares)
```

*note : le terme anglais pour les variables de sauvegarde est "savegame variable". Même si mes guides se concentreront sur la version française de Solarus, il n'est pas impossible que vous croisiez ce terme en anglais un certain nombre de fois.*

Pour bien saisir ce que sont ces variables et ce qu'elles représentent, il est important de bien comprendre que si une information peut être *conservée après avoir fermé le jeu*, alors elle fait obligatoirement partie des variables de sauvegarde.  
(De plus, lors d'un changement de map, les seules informations qui sont conservées sont les variables de sauvegarde, et celles stockées via les scripts Lua. Sachant que quasiment aucune donnée liée purement au *gameplay* n'est conservée directement dans les scripts Lua, on peut considérer que, côté gameplay, les seules informations conservées entre deux maps sont les variables de sauvegarde).

Les variables de sauvegarde sont chargées depuis le fichier de sauvegarde quand le jeu est lancé (c'est  dire quand le joueur à slectionné ou créé une save, dans l'écran de sélection de sauvegarde, et pas avant), et sauvegardées dans ce fichier quand le joueur décide de sauvegarder depuis le menu. Il faut donc bien comprendre qu'entre ces deux moments, le fichier de sauvegarde n'est jamais touché ; quand une variable de sauvegarde est modifée, c'est au niveau du jeu et non pas du fichier de sauvegarde, ce qui signifie que lorsque le jeu est fermé, toute modification apportée aux variables de sauvegarde depuis la dernière sauvegarde est oubliée.

![Image indisponible](img/savegame.PNG)

En soi, toutes les variables fonctionnent de la même manière, cependant il existe des différences au niveau de la manière dont elles sont crées/définies et modifiées.
- Les variables dont le nom commence par `_` sont celles crées et gérées intégralement par Solarus. Elles touchent donc généralement à des concepts et foncitonnalités présents de base dans Solarus, tels que les HP de Link, ou son point de réapparition.  
    ```
    Exemple : la variable "_current_money" (qui contient le nombre de rubis de link) est créée par solarus, et modifiée automatiquement quand le nombre de rubis de link change.
    ```

- Certaines variables sont gérées automatiquement par Solarus, mais créées par l'utilisateur (CàD : vous). Il s'agit généralement des variables associées à une entité, telle que les coffres ou les enemis (voir [Mapping](mapping.md)) : elles sont en effet créées par l'utilisateur, dans le sens où c'est vous qui décidez que tel ennemi (par exemple) est lié à une variable dont vous décidez du nom, cependant c'est Solarus qui s'occupera de la modifier, et qui utilisera sa valeur.



[Retour au sommaire](starting.md)

