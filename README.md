# guinea-piggies
This is a game about guinea piggies

# TODOs
- Add game juice
  - Slightly rotate cards when played (to not being perfectly in line -> a played card effect)
  - Add card count indicator to player profile image (smal circle with number in top right corner)
    - animation for number incread and decrease
  - Add a glow effect for hight value cards (like in https://imgur.com/QOCffyr)
  - Dissolve effect when card gets destroyed by predator
  - Animation of card movement from one player to the other if cards are obtained by predator card
  - Animation of card movement to player when end turn button clicked
  - Dissolve effect of cards if predator card is drawn
  - Add animation for Point
    - When turn ends and points are counted
      - Maybe: Progress bar filling up


# Possible Fonts collection:
- https://fonts.google.com/specimen/Ruge+Boogie?preview.text=Guinea%20Piggies&query=Ruge+Boogie
- https://fonts.google.com/specimen/Cherry+Bomb+One?preview.text=Guinea%20Piggies&query=Cherry+Bomb+One
- https://fonts.google.com/specimen/Acme?preview.text=Guinea%20Piggies
- https://fonts.google.com/specimen/Rubik+Bubbles?preview.text=Guinea%20Piggies&query=bub
- https://fonts.google.com/specimen/Poetsen+One?preview.text=Guinea%20Piggies

# Test Translations
By [set settings in editor](https://docs.godotengine.org/de/4.x/tutorials/i18n/internationalizing_games.html#testing-translations) or adding 

```gdscript
func _ready():
  TranslationServer.set_locale("en")
```

The full list of languages: [List](https://docs.godotengine.org/de/4.x/tutorials/i18n/locales.html#doc-locales)
