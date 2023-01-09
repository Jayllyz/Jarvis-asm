<h1 align="center"> Gift wrapping algorithm  </h1>

<p align="center">
  Assembly ESGI Project
</p>

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Description](#description)
- [Compilation](#compilation)
- [Contributors](#contributors)

## Description

The Gift Wrapping algorithm, also known as the Jarvis March, is an algorithm for finding the convex hull of a set of points in the plane. A convex hull is the smallest convex polygon that contains all of the points in a given set.

Here is a high-level overview of the steps involved in the Gift Wrapping algorithm:

1 - Choose a point on the convex hull as the starting point.

2 - Initialize an empty list to store the points on the convex hull.

3 - Set the current point to be the starting point.

4 - Find the point that is most counter-clockwise relative to the current point.

5 - If the found point is the starting point, return the list of points on the convex hull.

6 - Otherwise, add the found point to the list and set it to be the current point.

7 - Go back to step 4.

In this implementation, we also add one point to the list, and then we search if he is inside the convex hull.

## Compilation

```bash
su - # You need to be user root otherwise you will have seg fault.
compile64 jarvis.asm
exit
cd # Go to your project directory
./jarvis
```

## Contributors

[@userMeh](https://github.com/userMeh) & [@Jayllyz](https://github.com/Jayllyz) & [@Minatoco](https://github.com/minatoco)
