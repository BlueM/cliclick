Cliclick can emulate typing any character that can be typed on physical keyboard by hitting a regular key alone or combined with Shift and/or Alt, regardless of the keyboard layout.

In addition, in most keyboards layouts, there are characters which can be entered by typing two characters consecutively, typically with the first one being a so-called “dead” key or “combining character”. For instance, on a German keyboard, there is no key for typing “é”, but you can enter it by first typing a “combining acute accent” (Unicode U+0301) followed by “e”. Below you will find an overview of some keyboard layouts (or rather their English names) and lists of the characters which cliclick is able to type, as well as (very incomplete) lists of the characters which are known to be untypeable for
cliclick. If you find that cliclick cannot type a character you need, you might be interested in either adding code to support the keyboard layout (if cliclick does not know the layout at all) or in adding code on how to type the character using the current keyboard layout. The place to make these additions is method `getReplacementMapForKeyboardLayoutNamed:` in `KeycodeInformer.m`. The code in that method is pretty simple and you do not need to know much Objective-C to add more characters. This method is also the place from which data is read to auto-generate this file, so _do not edit it manually_.

Having said that, here is the list of keyboard layouts with the supported and (some) unsupported characters:

Canadian French - CSA
  * Supported: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÃÑÕãñõ
  * Unsupported: ŇŘŠňřšǸǹŃń (incomplete list)

French
  * Supported: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôû
  * Unsupported: ÃÑÕãñõŃńǸǹŇňŘřŠš (incomplete list)

German
  * Supported: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÃÕÑãõñ
  * Unsupported: ŃńǸǹŇňŘřŠš (incomplete list)

Italian
  * Supported: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÑñÃÕãõ
  * Unsupported: ŸŇŘŠňřšǸǹŃń (incomplete list)

Polish
  * Supported: ÄÖÜäöüÁÉÍÓÚáéíóúŃńŇňŘřŠš
  * Unsupported: ËÏŸëïÿÀÈÌÒÙàèìòùǸǹÂÊÎÔÛâêîôûÃÕÑãõñ (incomplete list)

Portuguese
  * Supported: ÄËÏÖÜäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÑñÃÕãõ
  * Unsupported: ŸŇŘŠňřšǸǹŃń (incomplete list)

Spanish
  * Supported: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÑñ
  * Unsupported: ÃÕãõŇŘŠňřšǸǹŃń (incomplete list)

U.S. Extended
  * Supported: ÄËÏÖÜŸäëïöüÿÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÂÊÎÔÛâêîôûÃÕÑãõñŃńǸǹŇňŘřŠš
  * Unsupported: [nothing]

