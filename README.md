# OrgNoteApp
Problem: How many times have you used X app for TODO list management? Y app for Journaling/ Daily logs? Z app for research note during solving A task from TODO item? 
For eaxmple: I use `AnyDo` for todo. `DayOne` for Journaling. `Evernote` for findings/research notes when doing some programming tasks. 
Solution: List of done takss from TODO can make for compelling/accurate Journal/Log. When working on a task its much nice to put notes into the task at the same place. 
          The promise of Org-Mode is to simplify these tasks and more into 1 place. It works great. Its a emacs major mode. For those interested please look into it. 
          Its awesome. This iOS client is supposed to the UI representation of subset of essential Org-Mode features. 
          

## User facing Features planned in:
- [] locate a org notes git repository (more support in future)
- [X] Render Org Mode items into List of items. The items are expandable/collapsable if the item has child/parent. 
- [ ] Log tap on item reveals utility bar of (edit/ delete/ add child / add sibling) buttons
- [ ] On any utility button tap, a bottom sheet pops up covering half the screen where user can interact with just the targetted item. 
- [ ] Once the user is done, the list renders to update the state. 
- [X] User can save the changes (this writes to the OrgFile format. Reverse of parsing.)
- [ ]   

## Technical Thigns to do:
- [X] Parsing of OrgMode file/string to Swift structs
Used ParserCombinators for this. Truly functional approach. 
- [X] Unit tests for Parsing, reverse parsing and org list driver. 
- [X] Fast Diffing algorithm to render views effeciently. 
- [ ] 
