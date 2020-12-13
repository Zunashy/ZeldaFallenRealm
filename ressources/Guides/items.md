# Items

Les items sont un concept très générique, et ainsi potentiellement peu intuitif.  
Chaque item possède un script, qui doit définir le comportement de cet Item vis-à-vis des nombreuses mécaniques liées aux Items.

On pourrait résumer les Items, grossièrement, comme le rassemblement de deux mécaniques distinctes : le fait de pouvoir **obtenir** quelque chose (qu'il s'agisse de rubis ou de l'épée), et le fait de pouvoir **utiliser** un item avec un effet particulier.  

Ces deux mécaniques sont bien distinctes : beaucoup d'items peuvent être obtenus mais pas vraiment "utilisés" (rubis, clés, coeurs, ...), et on pourrait tout à fait imaginer un item qui soit utilisable (c'est à dire assignable) sans que Link n'ait forcément besoin de le ramasser à un moment, même si, dans les faits, dans Fallen Realm tous les items peuvent/doivent être obtenus.  
Vous pouvez donc simplement vous dire qu'il existe un item pour chaque chose que Link peut **obtenir**.

## Variantes
Le concept de variante est assez difficile à expliquer pour l'instant, et sera beaucoup plus approfondi lorsque j'expliquerai plus précisément les différentes mécaniques liées aux Items : ce qu'il y a à savoir est simplement qu'une variante est un simple nombre ( > 0 ), qui va permettre d'identifier chaque version d'un item possédant plusieurs ... variantes, justement.  
Par exemple, dans le cas du rubis, tous les rubis sont le même item, cependant le rubis rouge est la variante 1, le rubis rouge la variante 3, etc.  
Lorsque Link obtient un Item, la méthode d'obtention indique généralement quelle variante de l'Item il obtient, et quand Link possède un Item (dans on inventaire) il en possède toujours un certaine variante.  
La sgnification de chaque numéro de variante dépend de l'Item, et de la manière dont il est programmé.

## Fonctionnalités

Bref, sans plonger tout de suite dans l'API, voici plus précisément les différentes fonctionnalités des Items.

### Obtention et possession
Un item peut être obtenu en plusieurs occasions : 
- Quand un [trésor ramassable](#trésor-ramassable) qui correspond à cet Item est ramassé par Link
- Quand Link ouvre un [coffre](mapping.md#Coffre) dont le contenu est cet Item 
- Il est aussi possible de faire obtenir un item manuellement, via les scripts.

(il est important de noter que quand Link obtient un item, il obtient toujours une certaine variante de cet item, c'est à dire que le trésor ramassable ou le coffre a été paramétré pour correspondre non seulement à cet Item, mais aussi à une certaine variante de l'Item.)

Lorsque Link obtient un item, tout d'abord une certaine fonction est lancée si elle est définie dans le script (ce qui permet de faire un item qui va avoir un effet immédiat à l'obtention, généralement en fonction de la variante obtenue). Ensuite, s'il s'agit d'un *Item sauvegardé*, Solarus se souvient que Link possède l'item.  

#### Items sauvegardés

Un Item sauvegardé est un item associé à une variable de sauvegarde (cette association se fait via le script, voir [Sauvegarde](save.md). Dès que Link obtient un Item sauvegardé, la variable de sauvegarde correspondante prend pour valeur la variante qui a été obtenue.   


```
Exemples : 
- Le rubis n'est pas un item sauvegardé. Quand Link en obtient un, une fonction du script lui ajoute un certain nombre de rubis, en fonction de la variante qui a été obtenue. Ainsi, s'il s'agissait d'un trésor ramassable qui indiquait que sa variante était 3, le script de l'Item rubis comprend qu'il s'agissait d'un rubis rouge et ajoute 20 rubis à Link (le nombre de rubis étant une valeur gérée en interne par Solarus)
- Obtenir la plume de roc n'a pas d'effet direct. Quand link l'obtient dans un coffre, rien se ne passe, mais vu que cet item a été associé à une variable de sauvegarde, la valeur de cette variable est passée à n, n étant la variante indiquée dans les paramètres du coffre (qui sera, dans notre cas, toujours 1 vu que la plume de roc n'a pas de variations. Il est en soi possible de la faire obtenir à Link avec une autre variante, mais ça n'aura pas spécialement d'intérêt).
```

(note : les variantes étant toujours d'au moins 1, si la valeur d'une variable de sauvegarde liée à un item est de 0, cela signifie que Link ne possède pas l'Item. On peut donc dire que Link possèed un item *si la variable qui y correspond existe ET possède une valeur supérieure à 0*).

#### Items à quantité

Il existe un système alternatif qui permet de faire en sorte que la variable de sauvegarde ne représentera pas une variante possédée, mais une quantité (pour cela, on utilise simplement une autre fonction pour associer la variable à l'Item). Cette variable contiendra un nombre, qui augmentera quand Link obtient l'Item.  
(on notera bien que ce n'est PAS le cas des rubis, le nombre de rubis de Link étant une valeur gérée de base par Solarus)

Notons bien que Link peut "perdre" un item : certains évènements peuvent faire que Link ne possède plus un item sauvegardé qu'il possédait (la variable liée passe alors à 0, peu importe la variante qui était possédée), et dans le cas d'un Item à quantité cette quantité peut baisser.  
Cela arrive notament avec les [portes](mapping.md#porte) : il est possible de paramétrer une porte de manière à ce qu'elle "décrémente ou retire" l'item nécessaire pour l'ouvrir.

#### Brandir un item

Une dernière chose : les Items peuvent être **brandis**. Lorsqu'un item est brandi, Link prend sa célèbre animation d'obtention d'item, l'Item en question est affiché au dessus de lui, un son est joué, et un dialogue est affiché (l'animation prend fin quand le dialogue est terminé). Le dialogue est récupéré automatiquement en fonction de l'item et de la variante (voir [Dialogues](dialogs.md)).  
Il est possible de paramétrer l'item de manière à être brandi, ou non à chaque fois qu'il est obtenu ; cependant un item obtenu dans un coffre sera toujours brandi.
```
Exemple : les quarts de coeurs sont toujours brandis quand ils sont obtenus, peu importe le contexte, cependant rien ne se passe quand link ramsse un rubis, par contre un rubis trouvé dans un coffre sera brandi. 
```

### Trésor ramassable
En soi, un trésor ramassable (ou pickable) n'est, tout comme le coffre, qu'[une entité](mapping.md#Trésor-ramassable) permettant à Link d'obtenir un certain Item. Il y a cependant deux subtilités : 
- Lorsqu'un trésor ramassable est créé (qu'il ait été placé directement sur la map, ou looté par un enemi), une certaine fonction du script de l'Item sera lancée, si elle est définie. Cela permet de donner un certain comportement/effet aux trésors ramassables correspondants à un certain Item (qui restent des entités)
- Le [sprite](sprites.md) du trésor ramassable est créé automatiquement, selon un fonctionnement bien particulier, décrit dans la seciton suivante.

### Affichage
Lorsque Solarus doit créer un sprite lié à un Item, notament, donc, pour un Trésor Ramassable, mais également lorsque Link brandit cet item, le fonctionnement est le suivant :
- Le sprite est toujours le même : `entities\items`
- L'animation est celle qui a le même nom que l'Item (ce sprite doit donc posséder une animation pour chaque Item)
- La direction correspond à la variante.

### Utilisation
Si un Item est sauvegardé, il est possible de le rendre assignable, ce qui signifie qu'il peut également être **assigné**. Solarus gère deux **slots** : chaque slot pouvant contenir un Item (assignable). La manière dont les Items sont assignés n'est pas définie de base par solarus (le seul moyen de le faire est via un script, en utilisant une certaine fonction) : dans Fallen Realm c'est à ça que sert le menu d'inventaire.  
Chacun des slots peut être associé à une touche du clavier (dans Fallen Realm ils sont associés à O et K) : lorsque le joueur appuie sur une de ces touches, l'Item que contient le slot correspondant est **utilisé**.  
L'effet d'un Item quand il est utilisé est défini dans une fonction de son script.  

## Les items de Fallen Realm

[Passer directement à la partie API](#lapi)

Pour illustrer par l'exemple toutes ces fonctionnalité (et parce qu'il est toujours utile d'avoir ce genre de liste), voici tous les items actuellement présents dans Fallen Realm : 

- ### Plume de roc / rock_feather
    La plume de roc est un simple item sauvegardé (sa variable de sauvegarde est `possession_rockfeather`) et assignable. Une fois utilisé, elle fait sauter Link (lui mpermettant de passer au dessus des trous et enemis).  
    Ainsi, une fois obtenue la plume de roc peut être assignée à un slot via le menu d'inventaire, suite à quoi si le joueur appuie sur la touche correspondant à ce slot, la fonction qui correspond à l'utilisation du l'item, dans son script, sera lancée et fera sauter Link.

- ### Petit coeur / heart
    Le petit coeur rend 4 HP (un coeur) à Link quand il est obtenu. Il n'est pas sauvegardé.

- ### Rubis /  rupee 
    Le rubis augmente la monnaie possédée par Link quand il obtenu. Il n'est pas sauvegardé.  
    La monnaie est une valeur gérée par solarus, et conservée via une variable de sauvegarde, modifiable via les scripts.  
    Selon la variante qui est obtenue, la fonction déclenchée lors de l'obtention ajoute une certaine quantité de monnaie (c'est à dire, un certain nombre de rubis, même si les rubis en tant que monnaie du jeu ne doivent pas être confondus avec l'Item rubis : encore une fois, le rubis n'est PAS un item à quantité) : 1/5/20/50/100 pour les variantes 1 à 5.

- ### Épée / sword
    Contrairement à ce qu'on pourrait croire, l'épée n'est pas un item sauvegardé. En effet, Solarus, gère tout seul le fait de donne des coups d'épées, et possède un système d'abilities, que Link peut posséder (chaque ability correspond à une variable de sauvegarde).  
    En gros, chaque ability permet à Link d'effectuer une certaine action, gérée par Solarus, s'il la possède : l'épée en fait partie, et si Link possède l'ability "sword" alors il donnera des coups d'épée quand le joueur appuie sur la touche assignés à l'épée (P dans fans Fallen Realm).  
    Ainsi, quand elle est obtenue l'épée donne cette cette ability à Link (via son script donc), ce qui signifie que le héros pourra donner des coups d'épée ; il n'est pas nécessaire de sauvegarder ces Item vu que Solarus se souvendra que Link possède l'ability "sword".  

- ### Essences / essence
    Les essences sont les objets récupérés à la fin des donjons. Il s'agit d'un seul et même Item sauvegardé (sa variable de sauvegarde est `essence`), et l'essence de chaque donjon a juste une variante différente. Ainsi, le trésor ramassable Essence qui est ramassé à la fin du donjon 2 a la variante 2, ce qui signifie que Link possèdera la variante 2 de l'essence (CàD : la valeur de la variable de sauvegarde `essence` sera 2) après avoir ramassé cette essence. 

- ### Grande Clé / great_key
    Simple item sauvegadé (sa variable est `great_key`), non assignable. La grande clé n'a pour ainsi dire aucun effet : elle ne sera utile que parce que certaines portes sont paramétrées pour laisser passer Link uniquement s'il possède cet Item, et une fois ouvertes retirer cet Item. 
    Ainsi, dès que Link essaie d'ouvrir une de ces portes et possède la Grande clé, peut importe la variante, la porte s'ouvre et la grande clé n'est plus possédée (la variable `great_key` passe à 0).  
    Si le fait d'avoir une grande clé d'une variante différente n'a pas d'effet réel, deux variantes en sont définies au niveau du sprite et des dialogues : la variante 1 est la Grande Clé classique, pour les donjons, et la variante 2 est la Clé du Donjon, qui a donc une apparence différente, et un dialogue d'obtention indiquant qu'elle sert à ouvrir l'entrée d'un donjon.

- ### Conteneur de coeur / heart_full
    Le conteneur de coeur ajoute un coeur à la barre de vie de Link, et lui restaure toute sa vie, quand il est obtenu. Il n'est pas sauvegardé.

- ### Quart de coeur / heart_quarter
    Le quart de coeur est un item à quantité (rappel : un item sauvegardé, dont la variable de sauvegarde désigne sa quantité, quantité qui augmente automatiquement à chaque fois que Link en obbtient un ; sa variable de sauvegarde de quantité est `heart_quarters`). Une fois que cette quantité atteint 4, elle est remise à 0 et Link gagne un coeur de plus.  

- ### Corne de Guerre / horn
    La Corne est un simple item sauvegardé (sa variable est `possesion_horn`), non assignable.  
    La corne peut être "utilisée", mais pas du point de vue de Solarus.  
    En effet, elle possède un effet (transporter Link dans l'autre monde), mais elle ne passe pas par le système d'assingation : en fait, le menu d'inventaire de Fallen Realm permet de la sélectionner pour activer son effet directement (en allant chercher "manuellement" une fonction du script de la corne).  
    Ainsi, une fois obtenue le menu d'inventaire de Fallen Realm permettra d'activer un effet (via une des fonctions de son script), comme si on l'utilisait, mais du point de vue de Solarus ce n'est pas un item utilisable.

- ### Random / random
    Le Random est un item qui ne sert qu'en tant que trésor ramassable. En effet, lorsqu'un trésor correspondant à cet Item est créé, le script de l'Item supprime ec trésor et le remplace par un autre au hasard (entre le coeur, le rubis et ... rien).  
    Il sert donc surtout en tant que loot d'enemi ou de destructible, puisque d'une fois qu'il apparaitra il sera remplacé par un rubis ou un coeur, au hasard, donnant l'illusion que l'ennemi/destructible a droppé un item au hasard.  
    Cet item ne peut pas être obtenu sous la forme d'un trésor ramssable, puisqu'il s'auto supprime dès qu'il apparait, cependant si Link était amené à l'obtenir dans un coffre, il ne se passerait strictement rien.

- ### Anneau octorok / ring_octorock
    Simple item sauvegardé (sa variable est `ring_octorok`), non assignable. Si la variante que possède Link est 1, les octorock ont moins d'HP quand ils apparaissent. Si cette variante est 2, en plus de ça ils infligent moins de dégats à Link.

- ### Graine de feu / fire_seed  
    La graine de feu est un simple item sauvegardé (sa variable de sauvegarde est `fire_seed_possession`) et assignable. Une fois utilisé, elle crée un flamme (entité custom) qui brûle tout végétal en contact, inflige des dêgats à Link et aux enemis qui entrent la touchent, et disparaît après 2 secondes.  

- ### Bracelet de force / bracelet
    De même que l'épée, contrairement à ce qu'on pourrait croire, le bracelet n'est pas un item sauvegardé car Le fait de soulever des rochers fait aussi partie des abilities dans Solarus.
    Ainsi, quand il est obtenu le Bracelet donne l'ability "lift" à Link, ce qui signifie qu'il pourra soulever les rochers.

- ### Petite clé / small_key
    La petite clé est un item à quantité (sa variable de sauvegarde de quantité est `small_keys`). Elles ne possèdent pas d'effet particulier, le but étant de paramétrer les portes à serrre de manière à être ouvrable par Link s'il possède cet Item (c'est à dire, pour le cas des items à quantité, s'il en possède *au moins une*), et à en retirer une le cas échéant.


Voilà pour la partie théorique, vous devriez a priori pouvoir comprendre le concept des items dans sa globalité, ainsi que le fonctionnement des items de Fallen Realm.

## L'API
On entre donc dans la partie pratique, si vous voulez programmer vous même un Item. 

### Introduction

A priori, vous savez déjà comment faire en théorie, c'est à dire quelles sont les fonctionnalités qu'il va falloir implémenter, nous allons donc voir commment faire tout ça en pratique, c'est à dire quelle fonctions utiliser et définir dans le script de votre Item.

> Évidemment, la programmation d'un Item requiert un minimum de connaissances en Lua. Je pars donc du principe, à partir d'ici, que vous connaissez au moins [les bases du langage](lua.md) et [la manière dont on utilise Lua avec Solarus](lua_solarus.md)

Premièrement, pour rappel le script d'un Item est défini par un fichier Lua portant le nom de l'item, dans le dossier `data/items` de la quête.  
Ce script aura pour but, comme la quasi-totalité des scripts Solarus, de définir des méthodes de l'objet item (ou events). Cet objet est déjà créé par solarus, et est désigné par le mot-clé `...`. De toute manière, tous les scripts d'items nouvellement créés contiennent déjà quelques ligne de code, dont un `local item = ...`, qui aura pour effet de stocker l'objet Item dans la variable éponyme.  

**Toutes les fonctions de l'objet item (qu'il s'agisse des fonctions fournies par Solarus (méthodes natives) ou des fonctions à créer (events)) sont listées dans [cette page de la documentation officielle](https://www.solarus-games.org/doc/latest/lua_api_item.html)**.

Note : grâce aux autres lignes de code présentes par défaut dans les scripts d'Items, vous avez dans tout le programme accès à une variable `game` qui contient l'objet de la partie en cours, et une variable `hero`, qui contient l'objet héros.

### Initialisation

La première fonction à ajouter à notre Item sera `on_created()`. Cette fonction est appelée dès que la `game` est créée, c'est à dire dès que le fichier de sauvegarde est chargé.  
C'est ici que vous allez appeler les méthodes qui permettent de configurer l'Item.  

Exemple : 
```lua
function item:on_created()
    --rappel : dans une méthode (=fonction appartenant à un objet), self désigne l'objet. Ici self = item.
    self:set_savegame_variable("possession_item")
    self:set_brandish_when_picked(true)
    self:set_assignable(true)
end 
```

Les principales fonctions utiles ici sont : 
- `item:set_savegame_variable(variable)` : définit la variable de sauvegarde associée. Fait implicitement de l'item un [Item sauvegardé](#items-sauvegardés).
- `item:set_amount_savegame_variable(variable)` : définit la variable de sauvegarde de quantité. Fait de l'item un [Item à quantité](#items-à-quantité).  
/!\ n'oubliez pas que les deux types de variable de sauvegarde peuvent coexister ! Un item peut très bien être un Item sauvegardé et à quantité en même temps.
-  `item:set_max_amount(max_amount)` : dans le cas d'un Item à quantité, définit la quantité maximum possédable.
- `item:set_assignable(assignable)` : indique si il est possible d'assigner l'item (`assignable` doit donc être true ou false. Ne rien mettre équivaut à true).
- `item:set_brandish_when_picked(brandish_when_picked)` : indique si Link doit [brandir](#brandir-un-item) cet Item en le ramassant (`brandish_when_picked` doit donc être true ou false. Ne rien mettre équivaut à true).

(il existe pas mal d'autres méthodes de configuration, que je ne liste pas ici car rarement utile)

Il est possible de faire certains items juste avec ça. Par exemple, item qui ne peut qu'être ramassé et utilisé par une autre fonctionnalité de Solarus (exemple : les clés avec les portes).

### Obtention

Une autre fonction qui sera présente dans beaucoup d'items est `on_obtained(variant, savegame_variable)`. Si vous la définissez, elle est appelée quand l'Item est obtenu, avec ces paramètres :  
- `variant` est la variant de l'item qui vient d'être obtenue.
- `savegame_variable` est la variable liée à cet item (ou nil pour un item non sauvegardé). Équivaut à `item:get_savegame_variable()` (présent uniquement parce que c'est plus pratique en gros)   

Premièrement, quand vous obtenez un Item sauvegardé, solarus change automatiquement la variante que vous possédez en la variante qui vient d'être obtenue. Si ce n'est pas ce que vous voulez, vous pouvez changer manuellement (dans cette fonction donc) la variant possédée actuellement, avec la méthode native `self:set_variant(variant)`.

Ensuite, pour les Items  à quantité, Solarus ne fait rien donc il faudra indiquer que la quantité que vous possédez a changé, avec les fonctions suivantes : 

- `self:set_amount(amount)` : définit la quantité acutellement possédée
- `self:add_amount(amount)` : ajoute une valeur à la quantité possédée

Exemple avec les coeurs :
```lua
function item:on_obtained(variant)
    game:add_life(4) --dès qu'un petit coeur est récupéré, on rend 4 quarts de coeur à Link.
end 
```

Pour les autres items, ou en général les Items qui doivent avoir un effet particulier à l'obtention, c'est ici que l'effet de l'item sera codé.  


Exemple : 
```lua
function item:on_obtained()
    self:add_amount(1)
end 
```

Il vous est également possible de contrôler vous même la variante qui est obtenue au final, avec `item:set_variant(variant)` 
> Rappel : comme la variante (et la quantité) sont conservées dans des variables de sauvegarde, `item:set_variant(variant)` équivaut à changer la variable de sauvegarde directement, soit à `item:get_game():set_value(item:get_savegame_variable(), variant)` (de même pour la quantité).

Note : dans le cas d'un item brandi, cette fonction est appelée juste après la fin de l'animation + dialogue. Il existe une fonction similaire, `item:on_obtaining(variant, savegame_variable)`, qui est appelée avant l'animation. Dans le cas d'un item non-brandi, les deux fonctions sont juste appelées  à la suite.

Il existe une autre fonction similaire, uniquement pour les Items sauvegardés : `item:on_variant_changed(variant)`. En plus de n'être appelée que pour un Item sauvegardé, elle n'est pas appelée si la variante qui a été obtenue était déjà celle que possédait le héros.  

### Utilisation
La fonction qui permettra d'implémenter l'[utilisation](#utilisation) d'un item assignable est `item:on_using()`.
Si un item est assignable, a été assigné à un slot, et est utilisé (i.e. la touche correspondant à ce slot a été appuyée), cette fonction est appelée.

Il est important de noter que l'utilisation d'un item place le héros dans un état bloqué, c'est à dire que le joueur perd le contrôle du héros dès qu'il utilise un item. La méthode native `item:set_finished()` de l'item utilisé remet le héros dans son état normal.
Cela signifie que la fonction `on_using()` doit appeler à un moment où à un autre (que ce soit à la fin de son éxécution, ou plus tard au moyen d'un Timer) `item:set_finished()`.  

Exemple avec la plume de roc : 
```lua
function item:on_using()
    hero:start_jumping_oow(32)
    sol.audio.play_sound("jump")
    item:set_finished()
end 
```

Lors de l'utilisation d'un item, une méthode native souvent utile est `item:get_variant()`. Elle renvoie la variante de l'item qui est possédée, et vous permet d'adapter son effet en fonction.

### Items ramassables
Lorsqu'un [trésor ramassable](#trésor-ramassable) est créé, c'est le script de l'Item correspondant qui détermine son fonctionnement, au moyen de la fonction `item:on_pickable_created(pickable)` (l'argument passé étant l'entité trésor ramassable), qui est appelée dès qu'un trésor ramassable correspondant à l'Item est créé.  
Dans cette fonction, vous pouvez configurer le trésor au moyen de toutes les méthodes natives de l'objet [pickable](), ainsi que définir ses events.  

### Autres méthodes natives
J'ai mentionné dans les sous-sections précédentes la plupart des méthodes natives des Items pouvant être utile dans les différents contextes évoqués, cependant il reste certaines méthodes natives qui pourrait être utiles dans d'autres contexte (notament dans un script qui n'est *pas* un script d'Item, mais qui doit quand même agir sur un Item (en le récupérant avec `game:get_item(name)`)).

- `item:is_assignable()` : indique si l'Item est assignable (renvoie un booléen)
- `item:get_amount()` : dans le cas d'un Item à quantité, renvoie la quantité possédée.
- `item:remove_amount(amount)` : dans le cas d'un Item à quantité, retire la quantité spécifiée.
- `item:is_being_used()` : dans le cas d'un Item assignable, indique s'il est en cours d'utilisation (i.e. il a été utilisé et `item:set_finished()`) n'a pas encore été appelée)

Exemple :
```lua
function item:on_pickable_created(pickable)

  if pickable:get_falling_height() ~= 0 then
    local trajectory = {
      { 0,  0},
        --j'abrège parce que c'est long
      {-1,  0}
    }
    local m = sol.movement.create("pixel")
    m:set_trajectory(trajectory)
    m:set_delay(100)
    m:set_loop(false)
    m:set_ignore_obstacles(true)
    m:start(pickable)
    pickable:get_sprite():set_animation("heart_falling")
  end
```

Note : si cette fonction n'est pas définie, Solarus applique un mouvement par défaut au pickable.

## Comment créer un item

### Collectible
> Pour créer un Item dont le but est simplement d'être collecté, comme les petites clés ou les Quarts de Coeur

Premièrement, cet items seront évidemment des items à quantité.  
On va donc commencer par paramétrer ça, dans le event approprié.  
```lua
function item:on_created()
    self:set_amount_savegame_variable("une_variable")
    --autres configurations
end
```

Ensuite, puisqu'il s'agit d'un Item à quantité il faut gérer manuellement son obtention, c'est à dire que dès que l'item est obtenu on ajoute une quantité. Cette quantité est souvent 1, mais pour certains Items elle peut dépendre de la variante (exemple : la variante 2 de l'Item est en fait un sac qui en contient 5).

```lua
function item:on_created(variant)
    local qantite = 1 --la quantité ajoutée par défaut est 1
    if variant > 1 then --si on a eu autre chose que la version (=variante) de basse de l'item
        qantite = 5 --en fait on obtient 5 fois l'item
    end
    self:add_amount(qantite) 
end
```

Attention, certains Items collectibles ne peuvent pas être obtenus dès le début. Le plus souvent on s'arrangera pour ne pas faire apparaître de trésors de cet Item si on ne peut pas encore l'obtenir, mais il peut être utile de gérer ce cas au cas où.  
De plus, n'oublions pas qu'un Item à quantité peut aussi être un Item sauvegardé, c'est à dire qu'un seul et même Item peut avoir à la fois une variante et une quantité conservée par Solarus.  
Illustrons donc ces deux principes avec un sac de bombes, où la variante 1 représenterait le sac (nécessaire pour collecter des bombes), la variante 2 une seule bombe et la variante 3 un sac de 5 bombes. Seul le sac peut 

```lua
function item:on_obtained(variant)
    if variant == 1 then -- si c'est le sac de bombes
        self:set_variant(1) --on indique qu'on le possède
        return --et on ne fait rien d'autre
    end 
    --à partir de là on est donc sûr qu'on a eu autre chose que le sac

    if self:get_variant() == 0 then --si on ne possède pas le sac
        return --on ne fait rien du tout
    end

    local qantite = 1 --la quantité ajoutée par défaut est 1
    if variant == 3 then --si on a eu le sac de 5 bombes (sinon c'est qu'on a eu la bombe seule)
        qantite = 5 --en fait on obtient 5 fois l'item
    end
    self:add_amount(qantite) 
end
```

Enfin, certains Items collectibles ont un effet direct lorsqu'il sont collectés, ou lorsqu'on en a récupéré un certain nombre. Dans certains cas, par exemple celui du Quart de Coeur, la quantité revient à 0 une fois qu'on en a assez pour activer l'effet : 
```lua
function item:on_obtained(variant)
    --on gère l'augmentation de la quantité ici

    if self:get_amount() > 3 then --si on en est à 4
        self:set_amount(0) --on revient à 0
        game:add_max_life(4) --on ajoute un coeur entier à la jauge de vie
    end
end
```

### Item assignable.

> Un Item au sens le plus évident du terme, qu'on va obtenir une fois, et pouvoir assigner à un des slots d'Items.

On commence comme d'habitude par la configuration, en indiquant que cet Item est assignable : de plus, ce sera aussi un Item sauvegardé. D'ailleurs il est important d'indiquer ça avant, car Solarus affiche une erreur si on tente de rendre un item non-sauvegardé assignable.

```lua
function item:on_created()
    self:set_savegame_variable("variable")
    self:set_assignable(true)
    --un item assignable est le plus souvent assez important/rare pour être brandi (cela dit, si on trouve l'item dans un coffre, cette ligne est inutile)
    self:set_brandish_when_picked(true)
end
```

Puis on fait en sorte que quand l'item est obtenu, la variante possédée soit mise à jour
```lua
function item:on_obtained(variant)
    self:set_variant(variant) --rien de bien complexe ici, la variante qu'on obtient devient la variante qu'on possède, de toute façon il y aura rarement plus d'une variante
```

Enfin, on définit la fonction qui sera appelée quand l'Item a été assigné et utilisé : 
```lua
function item:on_using()
    local variant = self:get_variant() --si l'item a plusieurs variantes on récupère la variante actuelle

    local map = game:get_map() --si on veut agir sur d'autres entités, on récupère la map (la variable map est déclarée au début du script, par défaut)

    if variant == 1 then 
        --on fait des trucs si on a la variante 1
    else
        --on fait d'autres trucs si on a une autre variante
    end
    self:set_finished() --on a fini avec l'effet de l'item, on rend le contrôle du héros au joueur
end 
```

Remarquez qu'on a placé le `item:set_finished()` directement dans la fonction, ce qui marche si l'effet est instantané. Ce n'est pas toujours la cas : imaginons un Item qui doit appliquer une certaine animation au héros, et dont l'utilisation se termine quand cette animation est finie.

```lua
local function item_end() --on définit une fonction simple, qui n'a rien à voir avec les méthodes/callbakcs de l'item
    item:set_finished() --son effet est simplement d'indiquer que 
end

end

function item:on_using()
    local sprite = hero:get_sprite() --on veut déclencher une animation du héros, on doit donc récupérer son objet sprite ; la variable hero est définie au début du script, par défaut
    sprite:set_animation("item_anim", item_end) --la méthode native set_animation des sprites, en plus de lancer l'animation spécifiée, peut prendre en second paramètre une fonction qui sera lancée quand l'animation se termine. Ainsi, dès que l'anim est terminée, solarus appellera notre item_end, qui mettra fin à l'utilisation de l'item.
end
```


[Retour au sommaire](starting.md)