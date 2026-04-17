# 🎡 Dizzy Running (කැරකී දිවීම)

මෙය සිංහල සහ දෙමළ අලුත් අවුරුදු උත්සව කාලය ඉලක්ක කර ගනිමින් Qbox Framework සඳහා නිර්මාණය කරන ලද, තාත්වික අත්දැකීමක් ලබා දෙන විනෝදජනක ක්‍රීඩා ස්ක්‍රිප්ට් එකකි.

## 🌟 විශේෂාංග (Features)

- **Realistic Spinning Mechanics**: ක්‍රීඩකයා පොල්ල හෝ ප්‍රොප් එක වටා අංශක 20ක ආනතියකින් (leaning) සහ ගැඹුරට නැමී (bent over) තාත්වික ලෙස කැරකීම සිදු කරයි.
- **Cinematic Camera**: කැරකෙන අවස්ථාවේදී ස්ක්‍රිප්ට් එක මඟින් පාලනය වන ස්ථාවර සහ සුමට කැමරා දර්ශනයක් (Scripted Camera) ලබා දේ.
- **Hard Mode System**: ක්‍රීඩකයා දිව යන විට ඉබේම දෙපසට ඇලවීම (Staggering), ඇස් පෙනීම තාවකාලිකව නැති වීම (Blackouts), පැනීම අවහිර කිරීම (Jump Restriction) සහ පාලනයන් උඩුයටිකුරු වීම (Control Inversion).
- **Global Cooldown**: එක් තරඟයක් අවසන් වූ පසු මුළු සර්වර් එකටම බලපාන පරිදි විවේක කාලයක් (Global Cooldown) සැකසිය හැක.
- **Automatic Cleanup**: ස්ක්‍රිප්ට් එක නතර කළහොත් (Resource Stop) හෝ ක්‍රීඩකයා ලොග් අවුට් වූවහොත් (Player Logout) සියලුම props සහ effects ස්වයංක්‍රීයව මැකී යයි.
- **Dynamic Goals**: සෑම තරඟයකදීම පද්ධතිය විසින් අහඹු ලෙස (Random) ඉලක්කයක් තෝරා ගනු ලබයි.
- **Ox Infrastructure**: සම්පූර්ණයෙන්ම `ox_lib`, `ox_target` සහ `ox_inventory` භාවිතා කරමින් උපරිම ක්‍රියාකාරීත්වයකින් (performance) නිර්මාණය කර ඇත.

## 🛠 ස්ථාපනය (Installation)

### 1. පූර්ව අවශ්‍යතා (Dependencies)
- `qbx_core`
- `ox_lib`
- `ox_target`
- `ox_inventory`

### 2. අයිතම එකතු කිරීම (Ox Inventory)
`ox_inventory/data/items.lua` ගොනුවට පහත අයිතම එකතු කරන්න:

```lua
['game_enter'] = {
    label = 'අවුරුදු ක්‍රීඩා ඇතුළත් වීමේ පත්‍රිකාව',
    weight = 10,
    stack = true,
    close = true,
},

['game_voucher'] = {
    label = 'ජයග්‍රාහී වොවුචරය',
    weight = 10,
    stack = true,
    close = true,
},
```

## ⚙️ වින්‍යාස කිරීම (Configuration)
`config.lua` ගොනුව මගින් පහත දෑ කළ හැක:
- **GlobalCooldown**: තරඟ දෙකක් අතර විවේක කාලය.
- **SpinAnimation**: කැරකෙන අවස්ථාවේ භාවිතා කරන animation එක (දැනට `amb@medic@standing@tendtodead@base` භාවිතා වේ).
- **HardMode**: stagger, trips, සහ jump restriction සැකසීම.
- **Goals**: අහඹු ලෙස තෝරා ගන්නා ඉලක්ක (Coords).

## 🎮 ක්‍රීඩා කරන ආකාරය (How it Works)
1. **ආරම්භය**: Prop එක වෙත ගොස් Target (Alt) මගින් තරඟය ආරම්භ කරන්න.
2. **කැරකීම**: ක්‍රීඩකයා පොල්ලට නැඹුරු වී කැරකෙන අතරතුර Cinematic Camera එක ක්‍රියාත්මක වේ.
3. **දිවීම**: කැරකීම අවසන් වූ පසු තිරය බොඳ වී පාලනයන් අභියෝගාත්මක වේ. පැනීමට උත්සාහ කළොත් හෝ වේගයෙන් දිවීමට උත්සාහ කළොත් වැටීමට (Ragdoll) ඉඩ ඇත.
4. **ජයග්‍රහණය**: සිතියමේ පෙනෙන කොළ පැහැති Marker එක වෙත නියමිත වේලාවට පෙර ළඟා වන්න.

---
**BenX Development Dizzy Running Script Pro © 2026**
