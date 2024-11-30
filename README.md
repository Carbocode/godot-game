## **Struttura di Cartelle per il Progetto**

```
project/
├── assets/                 # Risorse grezze non elaborate
│   ├── models/             # Modelli 3D
│   │   ├── characters/     # Modelli dei personaggi giocabili, NPC e mob
│   │   │   ├── player.glb
│   │   │   ├── npc_01.glb
│   │   │   └── mob_01.glb
│   │   ├── props/          # Oggetti di scena (singoli)
│   │   │   ├── table.glb
│   │   │   ├── chair.glb
│   │   │   └── tree.glb
│   │   └── structures/     # Strutture complesse
│   │       ├── house.glb
│   │       └── warehouse.glb
│   ├── textures/           # Texture per materiali e terrain
│   │   ├── ground/         # Texture per il terreno 2D
│   │   │   ├── grass.png
│   │   │   ├── dirt.png
│   │   └── objects/        # Texture per oggetti 3D
│   │       ├── wood.png
│   │       └── metal.png
│   ├── audio/              # Effetti sonori e musica
│   ├── fonts/              # Font per l'interfaccia
│   └── shaders/            # Shader personalizzati
│
├── scenes/                 # Scene principali e organizzazione logica
│   ├── characters/         # Scene relative ai personaggi
│   │   ├── player.tscn     # Giocatore
│   │   ├── npc_01.tscn     # NPC
│   │   └── mob_01.tscn     # Mob (nemici)
│   ├── world/              # Scene legate al mondo
│   │   ├── tiles/          # Singoli tile del terreno
│   │   │   ├── grass_tile.tscn
│   │   │   ├── dirt_tile.tscn
│   │   └── props/          # Oggetti individuali
│   │       ├── tree.tscn
│   │       ├── chair.tscn
│   │       └── table.tscn
│   │   ├── compositions/   # Composizioni di props
│   │   │   ├── campsite.tscn
│   │   │   └── market_stand.tscn
│   │   ├── maps/           # Scene per singole mappe
│   │   │   ├── test_map.tscn
│   │   │   ├── main_map.tscn
│   │   └── interactables/  # Oggetti con interazioni
│   │       ├── door.tscn
│   │       ├── loot_crate.tscn
│   │       └── light_post.tscn
│   ├── ui/                 # Interfaccia utente
│   │   ├── hud.tscn        # HUD principale
│   │   ├── inventory.tscn  # Menu dell'inventario
│   │   └── main_menu.tscn  # Menu principale
│   └── effects/            # Scene di effetti particellari o luci
│       ├── fire.tscn
│       └── smoke.tscn
│
├── scripts/                # Script organizzati per funzionalità
│   ├── core/               # Gestione centrale del gioco
│   │   ├── GameManager.gd  # Stato globale del gioco
│   │   ├── InputManager.gd # Gestione input
│   │   ├── SaveSystem.gd   # Salvataggio e caricamento
│   │   └── WorldManager.gd # Gestione del caricamento delle mappe
│   ├── characters/         # Script specifici per personaggi
│   │   ├── Player.gd       # Giocatore
│   │   ├── NPC.gd          # NPC
│   │   └── Mob.gd          # Nemico
│   ├── systems/            # Sistemi di gioco
│   │   ├── CombatSystem.gd # Sistema di combattimento
│   │   ├── InventorySystem.gd # Sistema di inventario
│   │   ├── CraftingSystem.gd  # Sistema di crafting
│   │   └── AIController.gd    # Intelligenza artificiale per mob/NPC
│   └── world/              # Script per il mondo e oggetti
│       ├── Tile.gd         # Script per tile del terreno
│       ├── Prop.gd         # Script generico per props
│       └── Interactable.gd # Script base per oggetti interattivi
│
├── resources/              # Risorse configurate e condivise
│   ├── tilesets/           # TileSet per il terreno
│   │   ├── terrain_tileset.tres
│   │   └── building_tileset.tres
│   ├── materials/          # Materiali configurati
│   │   ├── grass.material
│   │   ├── dirt.material
│   └── prefabs/            # Gruppi modulari per mappe
│       ├── trees/          # Gruppi di alberi
│       │   ├── tree_cluster.tscn
│       │   └── forest_patch.tscn
│       ├── buildings/      # Case prefabbricate
│       │   ├── small_house.tscn
│       │   └── large_house.tscn
│       ├── roads/          # Strade modulari
│       │   ├── road_straight.tscn
│       │   ├── road_curve.tscn
│       └── props/          # Gruppi di oggetti
│           ├── campfire.tscn
│           └── marketplace.tscn
│
└── autoloads/              # Singleton globali
    ├── Globals.gd          # Variabili e costanti globali
    ├── EventBus.gd         # Sistema di eventi globali
    └── AudioManager.gd     # Gestione dell'audio
```

---

## **Spiegazione della Struttura**

1. **Assets**:
   - Contiene le risorse di base (modelli, texture, audio) che possono essere riutilizzate e non sono ancora parte di una scena o prefabbricato.

2. **Scenes**:
   - **Characters**: Include i personaggi giocabili, NPC e mob, organizzati come scene separate.
   - **World**: Struttura chiara per gestire tiles, props, composizioni e mappe:
     - **Tiles**: Ogni tile rappresenta un pezzo del terreno in 2D, configurato con un materiale e uno script `Tile.gd`.
     - **Props**: Oggetti individuali come alberi, rocce, o sedie.
     - **Compositions**: Gruppi prefabbricati di props, come un campeggio o un mercato.
     - **Maps**: Mappe complete che combinano tiles, props e composizioni.
   - **UI**: Scene relative all'interfaccia utente.
   - **Effects**: Effetti visivi come fumo o fuoco.

3. **Scripts**:
   - Organizzati per categoria, con sistemi separati per personaggi, mondo, e gameplay generale.

4. **Resources**:
   - **Tilesets**: Configurazioni per i tile del terreno.
   - **Prefabs**: Gruppi prefabbricati che combinano props per semplificare la costruzione delle mappe.

5. **Autoloads**:
   - Singleton per gestire stato globale, eventi, e audio.
