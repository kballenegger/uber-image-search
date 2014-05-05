# Uber Google Image Search.


### The app and its UX

![UX](http://cl.ly/image/2C2p09351K00/2014-04-29%2023.55.51.jpg)

The app consists of three main screens:

1. The *Home* screen. This is what you see when you enter the app.
2. The *Query* screen. This is where you type in your query, and where you see the history of previous queries, filtered as you type.
3. The *Results* screen. It shows the images.

For the sake of saving time:

- I did not build a single result screen.
- I also did not consider how one might return to home screen, from any of the other two screens. For now, searching for the empty string does that.


### Architecture design decisions

- **No nibs**. Nibs make development quicker, but quickly become a liability when working on a larger production-quality project with a team. It's easy to make changes to the file accidentally, which are hard to detect in diffs. As soon as two engineers make changes to the same nib file in different branches, it becomes a nightmare to merge. I always create all interfaces in code.

- **CocoaPods**. CocoaPods is actually great, and is pretty much a requirement when using any third party code.

- **MVC**. This app is actually not a great candidate for MVC, so the pattern is barely used. The main example of MVC is in the separation of the view controllers.


### Third-party libraries used

- **AFNetworking**. It’s a large and very robust libraries that makes it a teeny bit easier to get started with the networking aspect.
- **ATValidation**. This is a library I wrote which performs data validation. It lets me enforce upfront that an API response looks the way I expect it to.


### Known issues

A few things I didn’t have time to fix:

- The history table view seems to be 20px too tall and end up going below the keyboard. Couldn’t figure out why right away, moved on.
- Animating from the home screen to the query / results screens looked a little funky. Disabled animations in the meantime.