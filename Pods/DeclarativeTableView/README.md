# Presenting a list of items (Getting started) 
Imagine wanting to put a array of items in a simple list and present it. Without the need to create table view subclass and go into delegate and datasource. 

## 1. Model 
```swift
let models = ["Apple", "Microsoft", "Google"]
```

## 2. Describe Cell for model
Describe what a cell would do for a single model. 
```swift
let cellDescs  = models.map { m -> ListCellDescriptor<String, SimpleCell> in
    var cd = ListCellDescriptor(m, identifier: identifier, cellClass: SimpleCell.self, 
    // 1. Configure 
    configure: { cell in
        cell.textLabel?.text = m
    })

    // set action handler
    cd.onSelect = { [weak self] in
        self?.tapped(m)
    }
    return cd
}
```

SimpleCell used above is just a empty subclass of normal UITableViewCell. Prefer to subclass and provide custom design that matches your business logic. 
```swift
class SimpleCell: UITableViewCell { }
```

## 3. Pack it into SectionDescriptors 
SectionDescriptors are just a way to group CellDescriptors. Think of them as array of each section's cell view model. 
```swift
/// A SectionDescriptor is made up of array of cell descriptor.
let sections = ListSectionDescriptor(with: cellDescs)
```

## 4. Construct ListViewController
```swift
/// A List is made of up array of section. 
let list = ListViewController(with: [sections])
```

## 5. Efficient updates 
If your model gets updated later on after the list is already on screen, simply pass the new `sectionDescriptors` to the list's `update` method. 

```swift
list.update(with: newSections)
```

The `ListViewController` uses `FastDiff`, a very fast diffing algorithm with time complexity of O(nm), to perform updates with standard table view animations. 

## 6. Present! 
That's it. 

**Note**  
So far we have seen how to present one *type* of model with single *type/variant* of cell. We even had just 1 section. This is called homogeneous typed list. 

Can we support multiple sections? 

# Advanced (Heterogeneous list)
First off this is how list is modelled.
```swift
List                    ==      [SectionDescriptor<T>] // 1
SectionDescriptor<T>    ==      [CellDescriptor<T,U>] where U: UITableViewCell // 2
```

With this approach 
1. A list can have same typed sections
2. Each section can have same typed cells
3. The type `T` is the model type. Since we can deduce U to subclass of UITableViewCell, its omitted in sections for brevity. 

Thus we can try to erase type of model `T` to `AnyHashable` to be able to construct heterogeneous list. This is made incredibly easy and safe by the library by exposing `any()` functions on both `ListCellDescriptor` and `SectionCellDescriptor`.

## 1. Using second section for new model
```swift
struct ModelItem: Hashable {
    let color: UIColor
    let int: Int
}

let modelsForNextSection = [ModelItem(color: .red, int: 1), .init(color: .blue, int: 2), .init(color: .purple, int: 3)]
```

## 2. Construct CellDescription like before 
```swift
let cellDescs2 = modelsForNextSection.map { m in
    return ListCellDescriptor(m, identifier: identifier2, cellClass: SimpleCell.self, configure: { cell in
        cell.textLabel?.text = "\(m.int)"
        cell.backgroundColor = m.color // setting color for the cell
    })
}

let secondSection = ListSectionDescriptor(with: cellDescs2)
```

## 3. Combine two different sections 
Given `ListSectionDescriptor<String>` and `ListSectionDescriptor<ModelItem>`, we need to pack them into single array. To do so, we erase model type. 
```swift
/// note the .any()
let combinedSections = [sections.any(), secondSection.any()]

let list = ListViewController(with: combinedSections)
```

**NOTE:**  
With this approach one can combine any kinds of cellDescriptors and sectionDescriptors without introducing the type erasure or casting while actually declaring both cellDescriptor and sectionDescriptor for particular models. 

<details>
    <summary>See picture for heterogeneous list</summary>

</details>

# Advanced (Heterogeneous list with mixed cells in a section)
## 1. Section with different model and cell
Imagine we want to present Int and String typed models in same section using SimpleCell and AnotherCell. 


```swift
class AnotherCell: UITableViewCell { }
```

```swift
let mc1 = ListCellDescriptor(1, identifier: "mc1", cellClass: SimpleCell.self, configure: { cell in
        cell.textLabel?.text = "\(1)"
    })

/// look out for cell identifier
let mc2 = ListCellDescriptor("hello", identifier: "mc2", cellClass: AnotherCell.self, configure: { cell in
        cell.textLabel?.text = "hello"
        cell.backgroundColor = .purple
    })
```

## 2. Construct sectionDescriptor
Now since we want to contain varying types of models in 1 section, our 
section has to be type erased. 

```swift
/// .any() on ListCellDescriptor
let mixedSection = ListSectionDescriptor(with: [mc1.any(), mc2.any()])
```

## 3. Present 
Just append it to the previous 2 examples we build upon and display.

```swift
let combinedSections = [sections.any(), secondSection.any(), mixedSection]
let list = ListViewController(with: combinedSections)
```

**NOTE:**   
This now gives us full power of having complete heterogeneous list if we choose to. 

# Advanced (Custom Action Handling)
TBD

# What's the pont?
This is a tiny library that eliminates rudimentary and repetitive UITableView subclassing, delegates and datasource handling for every simple list we want to present. It also provides efficient updates out of the box. Why not just declare what to make a list of and watch it. 

This is by no means a extensive list library, for that always use either UITableView or UICollectionView. This is useful in cases where you want to throw in a list either for demo, prototype or simple read only list. 