
# SwiftRex-ToDo-Persisted

Tinkering with persistence middleware for SwiftRex...

I'm a big fan of SwiftUI which seems (IMO) to be a good UI to use with Redux-like architectures. Having played around with a "roll-your-own" implementation, SwiftRex caught my eye due to type-safety features, integrated logging (via middleware)  and, very importantly for me, the detailed documentation and rapid support provided by the developer.

Having come from MVC and MVVM (albeit at a very amateur level), it has taken me some time to get my head around SwiftRex architecture because there are a significant number of components and the terminology was quite alien at first. The components are very lightweight but there's just so many (with a significant number of enums, associated values and generics) I must admit to struggle with following the flow of data and the transformations that take place. It is only though the considerable patience and assistance provided by @luizmb and @npvisual that I've managed to get as far as I have!

I'm using this app to get to grips with SwiftRex with a particular focus on how to implement Middleware and interface it with a persistance layer (Realm in this instance). I have shamelessly stolen from @npvisual's own ToDo prototype app (https://github.com/npvisual/ToDoList-Redux), which I pulled apart and rebuilt (with some minor stylistic changes) to help me understand structure and flow. In my iteration, the Persistence Middleware utilises a Realm service layer which I've gone some way to making generic although there is definitely a lot more that could be done to refactor (but I'm trying not to get bogged down in the details ATM).

There are definitely improvements that could be made to the UI and UX here but this is ultimately a learning exercise for me so comments, guidance and critique on the Redux-like "core" of the app is very much appreciated. The UI/UX is for another time...
