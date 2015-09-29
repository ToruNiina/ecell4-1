from cython.operator cimport dereference as deref
from cython cimport address, declare
from libcpp.vector cimport vector
from libcpp.pair cimport pair
from libcpp.string cimport string


cdef class Voxel:

    def __init__(self, Species sp, Integer coord, Real radius, Real D, loc=None):
        """Constructor.

        Args:
          sp (Species): The species.
          coord (Integer): The coordinate given as an Integer.
          radius (Real): The radius of a molecule.
          D (Real): The diffusion rate of a molecule.
          loc (str, optional): The location of a molecule.

        """
        pass  # XXX: Only used for doc string

    def __cinit__(self, Species sp, Integer coord, Real radius, Real D, loc=None):
        if loc is None:
            self.thisptr = new Cpp_Voxel(
                deref(sp.thisptr), coord, radius, D)
        else:
            self.thisptr = new Cpp_Voxel(
                deref(sp.thisptr), coord, radius, D, tostring(loc))

    def __dealloc__(self):
        del self.thisptr

    def coordinate(self):
        return self.thisptr.coordinate()

    def D(self):
        return self.thisptr.D()

    def radius(self):
        return self.thisptr.radius()

    def species(self):
        return Species_from_Cpp_Species(address(self.thisptr.species()))

    def loc(self):
        return self.thisptr.loc().decode('UTF-8')

cdef Voxel Voxel_from_Cpp_Voxel(Cpp_Voxel* p):
    cdef Cpp_Voxel *new_obj = new Cpp_Voxel(<Cpp_Voxel> deref(p))
    r = Voxel(Species(), 0, 0, 0)
    del r.thisptr
    r.thisptr = new_obj
    return r
