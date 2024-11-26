# E2 Library: ChatPrint
A utility function to print coloured text to a players chat area.

**IMPORTANT**: This library will only work if you have admin privileges, or `sbox_E2_ChatPrintAdminOnly` is set to 0.

Originally written by MattJeanes at https://github.com/MattJeanes/ChatPrint

# Usage

- chatPrint(`...`) - Prints a message to everybody's chat. Works similar to [chat.AddText(...)](https://wiki.facepunch.com/gmod/chat.AddText) and can take a variable number of arguments. Takes vectors as colors.

- chatPrint(`entity` targetPlayer, `...`) - Prints a message to a specific player's chat.

- chatPrint(`array` args) - Same as chatPrint(`...`) but takes an array of arguments.

- chatPrint(`entity` targetPlayer, `array` args) - Same as chatPrint(`entity`, `...`) but takes an array of arguments.

# Console Commands
- `sbox_E2_ChatPrintAdminOnly` - If set to 1, only admins can use chatPrint. This is enabled by default.
- `sbox_E2_ChatPrintMaxCharacters` - The maximum number of characters that can be in a single chatPrint message. Default is 255.
- `sbox_E2_ChatPrintBurstRate` - The rate at which the message limit recharges up to BurstMax, in messages per second. Default is 1 per second.
- `sbox_E2_ChatPrintBurstMax` - The maximum number of messages that can be sent in a burst. Default is 8.

# Examples

Prints "Hello world!" in green to the E2 owner's chat:
```golo
chatPrint(owner(), vec(0, 255, 0), "Hello world!")
```

Make all of your chat messages rainbow coloured for everyone:
```golo
@name Rainbow Chat
@strict

event chat(Player:entity, Message:string, _:number) {
    local R = array()

    R:pushVector(teamColor(owner():team()))
    R:pushString(owner():name())
    R:pushVector(vec(255, 255, 255))
    R:pushString(": ")

    for(I = 1, Message:length()) {
        local Color = hsv2rgb(360 / Message:length() * I, 1, 1)
        R:pushVector(Color)
        R:pushString(Message[I])
    }

    chatPrint(R)
    hideChat(1)
}
```