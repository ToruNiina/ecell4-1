from cython.operator cimport dereference as deref, preincrement as inc
from cython cimport address
from libcpp.string cimport string
from libcpp.vector cimport vector

from ecell4.types cimport *
from ecell4.shared_ptr cimport shared_ptr
from ecell4.core cimport *


## LatticeWorld
#  a python wrapper for Cpp_LatticeWorld
cdef class LatticeWorld:

    def __cinit__(self, Position3 edge_lengths, voxel_radius = None,
        GSLRandomNumberGenerator rng = None):
        if voxel_radius is None:
            self.thisptr = new shared_ptr[Cpp_LatticeWorld](
                new Cpp_LatticeWorld(deref(edge_lengths.thisptr)))
        elif rng is None:
            self.thisptr = new shared_ptr[Cpp_LatticeWorld](
                new Cpp_LatticeWorld(deref(edge_lengths.thisptr), voxel_radius))
        else:
            self.thisptr = new shared_ptr[Cpp_LatticeWorld](
                new Cpp_LatticeWorld(
                    deref(edge_lengths.thisptr), voxel_radius, deref(rng.thisptr)))

    def __dealloc__(self):
        # XXX: Here, we release shared pointer,
        #      and if reference count to the LatticeWorld object,
        #      it will be released automatically.
        del self.thisptr

    def set_t(self, Real t):
        self.thisptr.get().set_t(t)

    def t(self):
        return self.thisptr.get().t()

    def volume(self):
        return self.thisptr.get().volume()

    def new_particle(self, arg1, Position3 arg2=None):
        cdef pair[pair[Cpp_ParticleID, Cpp_Particle], bool] retval

        if arg2 is None:
            retval = self.thisptr.get().new_particle(deref((<Particle> arg1).thisptr))
        else:
            retval = self.thisptr.get().new_particle(deref((<Species> arg1).thisptr), deref(arg2.thisptr))
        return ((ParticleID_from_Cpp_ParticleID(address(retval.first.first)), Particle_from_Cpp_Particle(address(retval.first.second))), retval.second)

    def get_particle(self, ParticleID pid):
        cdef pair[Cpp_ParticleID, Cpp_Particle] \
            pid_particle_pair = self.thisptr.get().get_particle(deref(pid.thisptr))
        return (ParticleID_from_Cpp_ParticleID(address(pid_particle_pair.first)),
                Particle_from_Cpp_Particle(address(pid_particle_pair.second)))

    def get_voxel(self, ParticleID pid):
        cdef pair[Cpp_ParticleID, Cpp_Voxel] \
            pid_voxel_pair = self.thisptr.get().get_voxel(deref(pid.thisptr))
        return (ParticleID_from_Cpp_ParticleID(address(pid_voxel_pair.first)),
                Voxel_from_Cpp_Voxel(address(pid_voxel_pair.second)))

    def remove_particle(self, ParticleID pid):
        self.thisptr.get().remove_particle(deref(pid.thisptr))

    def remove_voxel(self, ParticleID pid):
        self.thisptr.get().remove_voxel(deref(pid.thisptr))

    def edge_lengths(self):
        cdef Cpp_Position3 lengths = self.thisptr.get().edge_lengths()
        return Position3_from_Cpp_Position3(address(lengths))

    def num_particles(self, Species sp):
        return self.thisptr.get().num_particles(deref(sp.thisptr))

    # def num_particles(self, Species sp = None):
    #     if sp is None:
    #         return self.thisptr.get().num_particles()
    #     else:
    #         return self.thisptr.get().num_particles(deref(sp.thisptr))

    def list_particles(self, Species sp = None):
        cdef vector[pair[Cpp_ParticleID, Cpp_Particle]] particles
        if sp is None:
            particles = self.thisptr.get().list_particles()
        else:
            particles = self.thisptr.get().list_particles(deref(sp.thisptr))

        retval = []
        cdef vector[pair[Cpp_ParticleID, Cpp_Particle]].iterator \
            it = particles.begin()
        while it != particles.end():
            retval.append(
                (ParticleID_from_Cpp_ParticleID(
                     <Cpp_ParticleID*>(address(deref(it).first))),
                 Particle_from_Cpp_Particle(
                     <Cpp_Particle*>(address(deref(it).second)))))
            inc(it)
        return retval

    def has_particle(self, ParticleID pid):
        return self.thisptr.get().has_particle(deref(pid.thisptr))

    def update_particle(self, ParticleID pid, Particle p):
        return self.thisptr.get().update_particle(deref(pid.thisptr), deref(p.thisptr))

    # def get_particle(self, ParticleID pid):
    #     cdef pair[Cpp_ParticleID, Cpp_Particle] \
    #         pid_particle_pair = self.thisptr.get().get_particle(deref(pid.thisptr))
    #     return (ParticleID_from_Cpp_ParticleID(address(pid_particle_pair.first)),
    #             Particle_from_Cpp_Particle(address(pid_particle_pair.second)))

    # def remove_particle(self, ParticleID pid):
    #     self.thisptr.get().remove_particle(deref(pid.thisptr))

    # def list_particles_within_radius(
    #     self, Position3 pos, Real radius,
    #     ParticleID ignore1 = None, ParticleID ignore2 = None):
    #     cdef vector[pair[pair[Cpp_ParticleID, Cpp_Particle], Real]] particles
    #     if ignore1 is None and ignore2 is None:
    #         particles = self.thisptr.get().list_particles_within_radius(
    #             deref(pos.thisptr), radius)
    #     elif ignore2 is None:
    #         particles = self.thisptr.get().list_particles_within_radius(
    #             deref(pos.thisptr), radius, deref(ignore1.thisptr))
    #     else:
    #         particles = self.thisptr.get().list_particles_within_radius(
    #             deref(pos.thisptr), radius,
    #             deref(ignore1.thisptr), deref(ignore2.thisptr))

    #     retval = []
    #     cdef vector[pair[pair[Cpp_ParticleID, Cpp_Particle], Real]].iterator \
    #         it = particles.begin()
    #     while it != particles.end():
    #         retval.append(
    #             ((ParticleID_from_Cpp_ParticleID(
    #                   <Cpp_ParticleID*>(address(deref(it).first.first))),
    #               Particle_from_Cpp_Particle(
    #                   <Cpp_Particle*>(address(deref(it).first.second)))),
    #              deref(it).second))
    #         inc(it)
    #     return retval

    # def periodic_transpose(self, Position3 pos1, Position3 pos2):
    #     cdef Cpp_Position3 newpos = self.thisptr.get().periodic_transpose(
    #         deref(pos1.thisptr), deref(pos2.thisptr))
    #     return Position3_from_Cpp_Position3(address(newpos))

    # def apply_boundary(self, Position3 pos):
    #     cdef Cpp_Position3 newpos = self.thisptr.get().apply_boundary(deref(pos.thisptr))
    #     return Position3_from_Cpp_Position3(address(newpos))

    # def distance_sq(self, Position3 pos1, Position3 pos2):
    #     return self.thisptr.get().distance_sq(deref(pos1.thisptr), deref(pos2.thisptr))

    # def distance(self, Position3 pos1, Position3 pos2):
    #     return self.thisptr.get().distance(deref(pos1.thisptr), deref(pos2.thisptr))

    # def volume(self):
    #     return self.thisptr.get().volume()

    # # def has_species(self, Species sp):
    # #     return self.thisptr.get().has_species(deref(sp.thisptr))

    def num_molecules(self, Species sp):
        return self.thisptr.get().num_molecules(deref(sp.thisptr))

    # # def add_species(self, Species sp):
    # #     self.thisptr.get().add_species(deref(sp.thisptr))

    def add_molecules(self, Species sp, Integer num):
        self.thisptr.get().add_molecules(deref(sp.thisptr), num)

    def remove_molecules(self, Species sp, Integer num):
        self.thisptr.get().remove_molecules(deref(sp.thisptr), num)

    def save(self, string filename):
        self.thisptr.get().save(filename)

    def load(self, string filename):
        self.thisptr.get().load(filename)

    def new_voxel(self, arg1, arg2=None):
        cdef pair[pair[Cpp_ParticleID, Cpp_Voxel], bool] retval

        if arg2 is None:
            retval = self.thisptr.get().new_voxel(deref((<Voxel> arg1).thisptr))
        else:
            retval = self.thisptr.get().new_voxel(deref((<Species> arg1).thisptr), <Integer> arg2)
        return ((ParticleID_from_Cpp_ParticleID(address(retval.first.first)), Voxel_from_Cpp_Voxel(address(retval.first.second))), retval.second)

    def update_voxel(self, ParticleID pid, Voxel v):
        return self.thisptr.get().update_voxel(deref(pid.thisptr), deref(v.thisptr))

    def list_voxels(self, Species sp):
        cdef vector[pair[Cpp_ParticleID, Cpp_Voxel]] voxels
        voxels = self.thisptr.get().list_voxels(deref(sp.thisptr))

        retval = []
        cdef vector[pair[Cpp_ParticleID, Cpp_Voxel]].iterator \
            it = voxels.begin()
        while it != voxels.end():
            retval.append(
                (ParticleID_from_Cpp_ParticleID(
                     <Cpp_ParticleID*>(address(deref(it).first))),
                 Voxel_from_Cpp_Voxel(
                     <Cpp_Voxel*>(address(deref(it).second)))))
            inc(it)
        return retval

    def has_voxel(self, ParticleID pid):
        return self.thisptr.get().has_voxel(deref(pid.thisptr))

    def voxel_radius(self):
        return self.thisptr.get().voxel_radius()

    def col_size(self):
        return self.thisptr.get().col_size()

    def row_size(self):
        return self.thisptr.get().row_size()

    def layer_size(self):
        return self.thisptr.get().layer_size()

    def size(self):
        return self.thisptr.get().size()

    def bind_to(self, NetworkModel m):
        self.thisptr.get().bind_to(deref(m.thisptr))

    def coordinate2position(self, Integer coord):
        cdef Cpp_Position3 pos = self.thisptr.get().coordinate2position(coord)
        return Position3_from_Cpp_Position3(address(pos))

    def position2coordinate(self, Position3 pos):
        return self.thisptr.get().position2coordinate(
            deref(pos.thisptr))

    def rng(self):
        return GSLRandomNumberGenerator_from_Cpp_RandomNumberGenerator(
            self.thisptr.get().rng())

cdef LatticeWorld LatticeWorld_from_Cpp_LatticeWorld(
    shared_ptr[Cpp_LatticeWorld] w):
    r = LatticeWorld(Position3(1, 1, 1))
    r.thisptr.swap(w)
    return r

## LatticeSimulator
#  a python wrapper for Cpp_LatticeSimulator
cdef class LatticeSimulator:

    def __cinit__(self, NetworkModel m, LatticeWorld w):
        self.thisptr = new Cpp_LatticeSimulator(
            deref(m.thisptr), deref(w.thisptr))

    def __dealloc__(self):
        del self.thisptr

    def num_steps(self):
        return self.thisptr.num_steps()

    def step(self, upto = None):
        if upto is None:
            self.thisptr.step()
        else:
            return self.thisptr.step(upto)

    def t(self):
        return self.thisptr.t()

    def dt(self):
        return self.thisptr.dt()

    def next_time(self):
        return self.thisptr.next_time()

    def set_dt(self, Real dt):
        self.thisptr.set_dt(dt)

    def initialize(self):
        self.thisptr.initialize()

    def model(self):
        return NetworkModel_from_Cpp_NetworkModel(self.thisptr.model())

    def world(self):
        return LatticeWorld_from_Cpp_LatticeWorld(self.thisptr.world())
