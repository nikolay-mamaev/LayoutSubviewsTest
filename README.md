LayoutSubviewsTest
==================

A sample project for the stackoverflow answer http://stackoverflow.com/a/24280489/1310204

Question:
------------

Let's have some view (`'Parent'`) with a subview (`'Child'`); let's animate this subview (`'Child'`); let's call `layoutSubviews` method of the `'Parent'` view and change `'Child'` subview's frame in this `layoutSubviews` method while animation is ongoing. What will happen?

Background Theory:
------------

`UIView` itself doesn't render any content; it's done by Core Animation layers. Each view has an associated `CALayer` which holds a bitmap snapshot of a view. In fact, `UIView` is just a thin component above Core Animation Layer which performs actual drawing using view's bitmap snapshots. Such mechanism optimizes drawing: rasterized bitmap can be rendered quickly by graphics hardware; bitmap snapshots are unchanged if a view structure is not changed, that is they are 'cahced'. 

Core Animation Layers hierarchy matches `UIView`'s hierarchy; that is, if some `UIView` has a subview, then a Core Animation layer corresponding to the container `UIView` has a sublayer corresponding to the subview.

Well... In fact, each `UIView` has even more than 1 corresponding `CALayer`. `UIView` hierarchy produces 3 matching Core Animation Layers trees:

* Layer Tree - these are layers we used to use through the `UIView`'s `layer` property
* Presentation Tree - layers containing the in-flight values for any running animations. Whereas the layer tree objects contain the target values for an animation, the objects in the presentation tree reflect the current values as they appear onscreen. You should never modify the objects in this tree. Instead, you use these objects to read current animation values, perhaps to create a new animation starting at those values.
* Objects in the render tree perform the actual animations and are private to Core Animation.

Change of UIView's properties such as frame is actually change of CALayer's property. That is, UIView's property is a wrapper around corresponding CALayer property.

Animation of UIView's frame is actually change of CALayer's frame; frame of the layer from Layer Tree is set to the target value immediately whereas change of frame value of layer from presentation tree is stretched in time. The following call:
    [UIView animateWithDuration:5 animations:^{
            CGRect frame = self.label.frame;
            frame.origin.y = 527;
            self.label.frame = frame;
        }];
doesn't mean that `self.label`'s `drawRect:` method will be called multiple times during next 5 seconds; it means that `y`-coordinate of the presentation tree's `CALayer` corresponding to the `self.label` will change incrementally from initial to target value during these 5 seconds, and `self.label`'s bitmap snapshot stored in this `CALayer` will be redrawn multiple times according to changes of its `y`-coordinate. 

Answer:
------------

Given this background, now we can answer the original question.

So, we have ongoing animation for a child view, and `layoutSubviews` method gets called for a parent view; in this method, child view's frame gets changed. It means that frame of a layer assiciated with the child view will be immediately set to the new value. At the same time, layer from the presentation tree has some intermidiate values (according to ongoing animation); setting new frame just changes target value for presentation tree layer, so that animation will continue from the current point to the new target.

That is, result of situation described in the original question is a 'jumping' animation. Please see demonstration in this GitHub sample project.