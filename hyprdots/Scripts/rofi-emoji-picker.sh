#!/bin/bash

HAPPY=$(printf "😀 Grinning Face\n😁 Beaming Face With Smiling Eyes\n😂 Face With Tears Of Joy\n😃 Smiling Face With Open Mouth\n😄 Smiling Face With Open Mouth\n😆 Laughing\n😊 Smiling Face With Smiling Eyes\n😎 Smiling Face With Sunglasses\n😜 Winking Face With Tongue\n😛 Face With Tongue\n😇 Smiling Face With Halo\n🤠 Cowboy Hat Face\n🤓 Nerd Face\n🤔 Thinking Face\n🤗 Hugging Face\n🤤 Drooling Face\n🤩 Star-Struck\n🤪 Zany Face\n🥳 Partying Face")

SAD=$(printf "😭 Loudly Crying Face\n😢 Crying Face\n😕 Confused Face\n😖 Confounded Face\n😟 Worried Face\n😔 Pensive Face\n😞 Disappointed Face\n😣 Persevering Face\n😥 Sad But Relieved Face\n😫 Tired Face\n😩 Weary Face\n🥺 Pleading Face\n💀 Skull")

EVIL=$(printf "😈 Smiling Face With Horns\n👹 Ogre\n👺 Goblin\n💀 Skull\n☠️ Skull And Crossbones\n👻 Ghost\n🧟 Zombie\n🧛 Vampire")

GESTURES=$(printf "🙌 Raising Hands\n👍 Thumbs Up\n👎 Thumbs Down\n✌️ Victory Hand\n🤝 Handshake\n👏 Clapping Hands\n🤘 Sign Of The Horns\n🖐️ Raised Hand\n🤚 Raised Back Of Hand")

ANIMALS=$(printf "🐶 Dog Face\n🐱 Cat Face\n🐭 Mouse Face\n🐹 Hamster Face\n🐰 Rabbit Face\n🦊 Fox Face\n🐻 Bear Face\n🐼 Panda Face\n🐨 Koala\n🐯 Tiger Face\n🦁 Lion Face\n🐸 Frog Face")

FOOD=$(printf "🍎 Red Apple\n🍌 Banana\n🍕 Pizza\n🍔 Hamburger\n🍣 Sushi\n🍪 Cookie\n🥑 Avocado\n☕ Coffee\n🥤 Cup With Straw\n🍩 Doughnut\n🍉 Watermelon")

OBJECTS=$(printf "💎 Gem Stone\n💡 Light Bulb\n💼 Briefcase\n📚 Books\n📅 Calendar\n📞 Telephone Receiver\n📝 Memo\n🎁 Wrapped Gift\n🛠️ Hammer And Wrench\n⌛ Hourglass\n🔋 Battery\n🔦 Flashlight")

SYMBOLS=$(printf "✅ Check Mark Button\n❤️ Red Heart\n🔥 Fire\n🌈 Rainbow\n🌟 Glowing Star\n✨ Sparkles\n🎯 Direct Hit\n🔒 Locked\n🔑 Key\n💸 Money With Wings\n🔔 Bell")

category=$(printf "🐶 Animals\n💀 Evil\n😊 Happy\n😢 Sad\n👋 Gestures\n🍔 Food\n📦 Objects\n🔣 Symbols" | sort | rofi -config /home/leg/.config/rofi/application-launcher/config.rasi -style /home/leg/.config/rofi/application-launcher/theme.rasi -dmenu -prompt "Pick category" --width 300 --height 220)

[[ -z "$category" ]] && exit 0

case "$category" in
  "😊 Happy") list="$HAPPY" ;;
  "😢 Sad") list="$SAD" ;;
  "👋 Gestures") list="$GESTURES" ;;
  "🐶 Animals") list="$ANIMALS" ;;
  "🍔 Food") list="$FOOD" ;;
  "📦 Objects") list="$OBJECTS" ;;
  "🔣 Symbols") list="$SYMBOLS" ;;
  "💀 Evil") list="$EVIL" ;;
  *) exit 1 ;;
esac

chosen=$(printf "%s\n" "$list" | sort -k2 | rofi -config /home/leg/.config/rofi/application-launcher/config.rasi -style /home/leg/.config/rofi/application-launcher/theme.rasi -dmenu -prompt "Pick emoji" --width 300 --height 400)

[[ -z "$chosen" ]] && exit 0

emoji=$(echo "$chosen" | awk '{print $1}')

printf "%s" "$emoji" | wl-copy

notify-send "Emoji copied" "$emoji"

