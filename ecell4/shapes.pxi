from cython.operator cimport dereference as deref
from cython cimport address


cdef class Shape:
    """A wrapper for a base class of Shapes.

    Warning: This is mainly for developers.
    Do not use this for your simulation.
    """

    def __cinit__(self):
        self.thisptr = new shared_ptr[Cpp_Shape](
            <Cpp_Shape*>(new Cpp_Sphere())) #XXX: DUMMY

    def __dealloc__(self):
        del self.thisptr

    def is_inside(self, Real3 pos):
        """"Return if the given point is inside or not.

        Args:
          pos (Real3): A position.

        Returns:
          value (float): Zero or negative if the given point is inside.

        """
        return self.thisptr.get().is_inside(deref(pos.thisptr))

    def dimension(self):
        """Return a dimension of this shape."""
        return self.thisptr.get().dimension()

cdef class Sphere:
    """A class representing a sphere shape, which is available to define
    structures.

    Sphere(center, radius)

    """

    def __init__(self, Real3 center, Real radius):
        """Constructor.

        Args:
          center (Real3): The center position of a sphere.
          radius (float): The radius of a sphere.

        """
        pass  # XXX: Only used for doc string

    def __cinit__(self, Real3 center, Real radius):
        self.thisptr = new shared_ptr[Cpp_Sphere](
            new Cpp_Sphere(deref(center.thisptr), radius))

    def __dealloc__(self):
        del self.thisptr

    def dimension(self):
        """Return a dimension of this shape."""
        return self.thisptr.get().dimension()

    def distance(self, Real3 pos):
        """Return a minimum distance from the given point to the surface.

        Args:
          pos (Real3): A position.

        Returns:
          distance (float): A minimum distance from the given point.
            Negative if the given point is inside.

        """
        return self.thisptr.get().distance(deref(pos.thisptr))

    def is_inside(self, Real3 pos):
        """"Return if the given point is inside or not.

        Args:
          pos (Real3): A position.

        Returns:
          value (float): Zero or negative if the given point is inside.

        """
        return self.thisptr.get().is_inside(deref(pos.thisptr))

    def surface(self):
        """Create and return a surface shape.

        Returns:
          shape (SphericalSurface): The surface shape.

        """
        cdef Cpp_SphericalSurface shape = self.thisptr.get().surface()
        return SphericalSurface_from_Cpp_SphericalSurface(address(shape))

    def as_base(self):
        """Clone self as a base class. This function is for developers."""
        cdef shared_ptr[Cpp_Shape] *new_obj = new shared_ptr[Cpp_Shape](
            <Cpp_Shape*>(new Cpp_Sphere(
                <Cpp_Sphere> deref(self.thisptr.get()))))
        retval = Shape()
        del retval.thisptr
        retval.thisptr = new_obj
        return retval

cdef class SphericalSurface:
    """A class representing a hollow spherical surface, which is
    available to define structures.

    SphericalSurface(center, radius)

    """

    def __init__(self, Real3 center, Real radius):
        """Constructor.

        Args:
          center (Real3): The center position of a sphere.
          radius (float): The radius of a sphere.

        """
        pass  # XXX: Only used for doc string

    def __cinit__(self, Real3 center, Real radius):
        self.thisptr = new shared_ptr[Cpp_SphericalSurface](
            new Cpp_SphericalSurface(deref(center.thisptr), radius))

    def __dealloc__(self):
        del self.thisptr

    def dimension(self):
        """Return a dimension of this shape."""
        return self.thisptr.get().dimension()

    def distance(self, Real3 pos):
        """Return a minimum distance from the given point to the surface.

        Args:
          pos (Real3): A position.

        Returns:
          distance (float): A minimum distance from the given point.
            Negative if the given point is inside.

        """
        return self.thisptr.get().distance(deref(pos.thisptr))

    def is_inside(self, Real3 pos):
        """"Return if the given point is inside or not.

        Args:
          pos (Real3): A position.

        Returns:
          value (float): Zero or negative if the given point is inside.

        """
        return self.thisptr.get().is_inside(deref(pos.thisptr))

    def inside(self):
        """Create and return a volume shape.

        Returns:
          shape (Sphere): The volume shape.

        """
        cdef Cpp_Sphere shape = self.thisptr.get().inside()
        return Sphere_from_Cpp_Sphere(address(shape))

    def as_base(self):
        """Clone self as a base class. This function is for developers."""
        cdef shared_ptr[Cpp_Shape] *new_obj = new shared_ptr[Cpp_Shape](
            <Cpp_Shape*>(new Cpp_SphericalSurface(
                <Cpp_SphericalSurface> deref(self.thisptr.get()))))
        retval = Shape()
        del retval.thisptr
        retval.thisptr = new_obj
        return retval

cdef class PlanarSurface:
    """A class representing a planar surface, which is available to define
    structures.

    PlanarSurface(origin, e0, e1)

    """

    def __init__(self, Real3 origin, Real3 e0, Real3 e1):
        """Constructor.

        Args:
          origin (Real3): A position on the plane.
          e0 (Real3): The first vector along the plane.
          e1 (Real3): The second vector along the plane.
            e0 and e1 must not be parallel.
            e0 and e1 is not needed to be an unit vector.

        """
        pass  # XXX: Only used for doc string

    def __cinit__(self, Real3 origin, Real3 e0, Real3 e1):
        self.thisptr = new shared_ptr[Cpp_PlanarSurface](
            new Cpp_PlanarSurface(deref(origin.thisptr),
                deref(e0.thisptr), deref(e1.thisptr)))

    def __dealloc__(self):
        del self.thisptr

    # def distance(self, Real3 pos):
    #     """Return a minimum distance from the given point to the surface.

    #     Args:
    #       pos (Real3): A position.

    #     Returns:
    #       distance (float): A minimum distance from the given point.
    #         Negative if the given point is inside.

    #     """
    #     return self.thisptr.get().distance(deref(pos.thisptr))

    def dimension(self):
        """Return a dimension of this shape."""
        return self.thisptr.get().dimension()

    def is_inside(self, Real3 pos):
        """"Return if the given point is inside or not.

        Args:
          pos (Real3): A position.

        Returns:
          value (float): Zero or negative if the given point is inside.

        """
        return self.thisptr.get().is_inside(deref(pos.thisptr))

    def as_base(self):
        """Clone self as a base class. This function is for developers."""
        cdef shared_ptr[Cpp_Shape] *new_obj = new shared_ptr[Cpp_Shape](
            <Cpp_Shape*>(new Cpp_PlanarSurface(
                <Cpp_PlanarSurface> deref(self.thisptr.get()))))
        retval = Shape()
        del retval.thisptr
        retval.thisptr = new_obj
        return retval

cdef class Rod:
    """A class representing a Rod shape, which is available to define
    structures. The cylinder is aligned to x-axis.

    Rod(length, radius, origin=Real3(0, 0, 0))

    """

    def __init__(self, Real length, Real radius,
                 Real3 origin = Real3(0, 0, 0)):
        """Constructor.

        Args:
          length (float): The length of a cylinder part of a rod.
          radius (float): The radius of a cylinder and sphere caps.
          origin (Real3, optional): The center position of a rod.

        """
        pass  # XXX: Only used for doc string

    def __cinit__(self, Real length, Real radius,
                  Real3 origin = Real3(0, 0, 0)):
        self.thisptr = new shared_ptr[Cpp_Rod](
            new Cpp_Rod(length, radius, deref(origin.thisptr)))

    def __dealloc__(self):
        del self.thisptr;

    def dimension(self):
        """Return a dimension of this shape."""
        return self.thisptr.get().dimension()

    def distance(self, Real3 pos):
        """Return a minimum distance from the given point to the surface.

        Args:
          pos (Real3): A position.

        Returns:
          distance (float): A minimum distance from the given point.
            Negative if the given point is inside.

        """
        return self.thisptr.get().distance(deref(pos.thisptr))

    def is_inside(self, Real3 pos):
        """"Return if the given point is inside or not.

        Args:
          pos (Real3): A position.

        Returns:
          value (float): Zero or negative if the given point is inside.

        """
        return self.thisptr.get().is_inside(deref(pos.thisptr))

    def origin(self):
        """Return a center position of mass"""
        cdef Cpp_Real3 origin = self.thisptr.get().origin()
        return Real3_from_Cpp_Real3(address(origin))

    def shift(self, Real3 vec):
        """Move the center toward the given displacement

        Args:
          vec (Real3): A displacement.

        """
        self.thisptr.get().shift(deref(vec.thisptr))

    def surface(self):
        """Create and return a surface shape.

        Returns:
          shape (RodSurface): The surface shape.

        """
        cdef Cpp_RodSurface surface = self.thisptr.get().surface()
        return RodSurface_from_Cpp_RodSurface(address(surface))

    def as_base(self):
        """Clone self as a base class. This function is for developers."""
        cdef shared_ptr[Cpp_Shape] *new_obj = new shared_ptr[Cpp_Shape](
            <Cpp_Shape*>(new Cpp_Rod(<Cpp_Rod> deref(self.thisptr.get()))))
        retval = Shape()
        del retval.thisptr
        retval.thisptr = new_obj
        return retval

cdef class RodSurface:
    """A class representing a hollow rod surface shape, which is
    available to define structures. The cylinder is aligned to x-axis.

    RodSurface(length, radius, origin=Real3(0, 0, 0))

    """

    def __init__(self, Real length, Real radius,
                 Real3 origin = Real3(0, 0, 0)):
        """Constructor.

        Args:
          length (float): The length of a cylinder part of a rod.
          radius (float): The radius of a cylinder and sphere caps.
          origin (Real3, optional): The center position of a rod.

        """
        pass  # XXX: Only used for doc string


    def __cinit__(self, Real length, Real radius,
                  Real3 origin = Real3(0, 0, 0)):
        self.thisptr = new shared_ptr[Cpp_RodSurface](
            new Cpp_RodSurface(length, radius, deref(origin.thisptr)))

    def __dealloc__(self):
        del self.thisptr

    def dimension(self):
        """Return a dimension of this shape."""
        return self.thisptr.get().dimension()

    def distance(self, Real3 pos):
        """Return a minimum distance from the given point to the surface.

        Args:
          pos (Real3): A position.

        Returns:
          distance (float): A minimum distance from the given point.
            Negative if the given point is inside.

        """
        return self.thisptr.get().distance(deref(pos.thisptr))

    def is_inside(self, Real3 pos):
        """"Return if the given point is inside or not.

        Args:
          pos (Real3): A position.

        Returns:
          value (float): Zero or negative if the given point is inside.

        """
        return self.thisptr.get().is_inside(deref(pos.thisptr))

    def origin(self):
        """Return a center position of mass"""
        cdef Cpp_Real3 origin = self.thisptr.get().origin()
        return Real3_from_Cpp_Real3(address(origin))

    def shift(self, Real3 vec):
        """Move the center toward the given displacement

        Args:
          vec (Real3): A displacement.

        """
        self.thisptr.get().shift(deref(vec.thisptr))

    def inside(self):
        """Create and return a volume shape.

        Returns:
          shape (Rod): The volume shape.

        """
        cdef Cpp_Rod shape = self.thisptr.get().inside()
        return Rod_from_Cpp_Rod(address(shape))

    def as_base(self):
        """Clone self as a base class. This function is for developers."""
        cdef shared_ptr[Cpp_Shape] *new_obj = new shared_ptr[Cpp_Shape](
            <Cpp_Shape*>(new Cpp_RodSurface(
                <Cpp_RodSurface> deref(self.thisptr.get()))))
        retval = Shape()
        del retval.thisptr
        retval.thisptr = new_obj
        return retval

cdef class AABB:
    """A class representing an axis aligned bounding box (AABB),
    which is available to define structures.

    AABB(lower, upper)

    """

    def __init__(self, Real3 lower, Real3 upper):
        """Constructor.

        Args:
          lower (Real3): A vertex suggesting the lower bounds.
          upper (Real3): A vertex suggesting the upper bounds.

        """
        pass  # XXX: Only used for doc string

    def __cinit__(self, Real3 lower, Real3 upper):
        self.thisptr = new shared_ptr[Cpp_AABB](
            new Cpp_AABB(deref(lower.thisptr), deref(upper.thisptr)))

    def __dealloc__(self):
        del self.thisptr

    def dimension(self):
        """Return a dimension of this shape."""
        return self.thisptr.get().dimension()

    def distance(self, Real3 pos):
        """Return a minimum distance from the given point to the surface.

        Args:
          pos (Real3): A position.

        Returns:
          distance (float): A minimum distance from the given point.
            Negative if the given point is inside.

        """
        return self.thisptr.get().distance(deref(pos.thisptr))

    def is_inside(self, Real3 pos):
        """"Return if the given point is inside or not.

        Args:
          pos (Real3): A position.

        Returns:
          value (float): Zero or negative if the given point is inside.

        """
        return self.thisptr.get().is_inside(deref(pos.thisptr))

    def upper(self):
        """Return a vertex suggesting the upper bounds."""
        cdef Cpp_Real3 pos = self.thisptr.get().upper()
        return Real3_from_Cpp_Real3(address(pos))

    def lower(self):
        """Return a vertex suggesting the lower bounds."""
        cdef Cpp_Real3 pos = self.thisptr.get().lower()
        return Real3_from_Cpp_Real3(address(pos))

    def as_base(self):
        """Clone self as a base class. This function is for developers."""
        cdef shared_ptr[Cpp_Shape] *new_obj = new shared_ptr[Cpp_Shape](
            <Cpp_Shape*>(new Cpp_AABB(<Cpp_AABB> deref(self.thisptr.get()))))
        retval = Shape()
        del retval.thisptr
        retval.thisptr = new_obj
        return retval

cdef class MeshSurface:
    """A class representing a triangular mesh surface, which is
    available to define structures.
    The polygonal shape is given as a STL (STereoLithography) format.
    This object needs VTK support.
    """

    def __init__(self, string filename, Real3 edge_lengths):
        """Constructor.

        Args:
          filename (str): An input file name given in STL format.
          edge_lengths (Real3): Bounds.
            The object is automatically resized to fit into the
            given lengths.

        """
    def __cinit__(self, string filename, Real3 edge_lengths):
        self.thisptr = new shared_ptr[Cpp_MeshSurface](
            new Cpp_MeshSurface(filename, deref(edge_lengths.thisptr)))

    def __dealloc__(self):
        del self.thisptr

    # def distance(self, Real3 pos):
    #     """Return a minimum distance from the given point to the surface.

    #     Args:
    #       pos (Real3): A position.

    #     Returns:
    #       distance (float): A minimum distance from the given point.
    #         Negative if the given point is inside.

    #     """
    #     return self.thisptr.get().distance(deref(pos.thisptr))

    def dimension(self):
        """Return a dimension of this shape."""
        return self.thisptr.get().dimension()

    def is_inside(self, Real3 pos):
        """"Return if the given point is inside or not.

        Args:
          pos (Real3): A position.

        Returns:
          value (float): Zero or negative if the given point is inside.

        """
        return self.thisptr.get().is_inside(deref(pos.thisptr))

    def as_base(self):
        """Clone self as a base class. This function is for developers."""
        cdef shared_ptr[Cpp_Shape] *new_obj = new shared_ptr[Cpp_Shape](
            <Cpp_Shape*>(new Cpp_MeshSurface(
                <Cpp_MeshSurface> deref(self.thisptr.get()))))
        retval = Shape()
        del retval.thisptr
        retval.thisptr = new_obj
        return retval

cdef Sphere Sphere_from_Cpp_Sphere(Cpp_Sphere* shape):
    cdef shared_ptr[Cpp_Sphere] *new_obj = new shared_ptr[Cpp_Sphere](
        new Cpp_Sphere(<Cpp_Sphere> deref(shape)))
    retval = Sphere(Real3(0, 0, 0), 0)
    del retval.thisptr
    retval.thisptr = new_obj
    return retval

cdef SphericalSurface SphericalSurface_from_Cpp_SphericalSurface(
        Cpp_SphericalSurface* shape):
    cdef shared_ptr[Cpp_SphericalSurface] *new_obj = new shared_ptr[Cpp_SphericalSurface](
        new Cpp_SphericalSurface(<Cpp_SphericalSurface> deref(shape)))
    retval = SphericalSurface(Real3(0, 0, 0), 0)
    del retval.thisptr
    retval.thisptr = new_obj
    return retval

cdef Rod Rod_from_Cpp_Rod(Cpp_Rod* shape):
    cdef shared_ptr[Cpp_Rod] *new_obj = new shared_ptr[Cpp_Rod](
        new Cpp_Rod(<Cpp_Rod> deref(shape)))
    retval = Rod(0.5e-6, 2e-6)
    del retval.thisptr
    retval.thisptr = new_obj
    return retval

cdef RodSurface RodSurface_from_Cpp_RodSurface(Cpp_RodSurface* shape):
    cdef shared_ptr[Cpp_RodSurface] *new_obj = new shared_ptr[Cpp_RodSurface](
        new Cpp_RodSurface(<Cpp_RodSurface> deref(shape)))
    retval = RodSurface(0.5e-6, 2e-6)
    del retval.thisptr
    retval.thisptr = new_obj
    return retval

cdef AABB AABB_from_Cpp_AABB(Cpp_AABB* shape):
    cdef shared_ptr[Cpp_AABB] *new_obj = new shared_ptr[Cpp_AABB](
        new Cpp_AABB(<Cpp_AABB> deref(shape)))
    retval = AABB(Real3(0, 0, 0), Real3(0, 0, 0))
    del retval.thisptr
    retval.thisptr = new_obj
    return retval

