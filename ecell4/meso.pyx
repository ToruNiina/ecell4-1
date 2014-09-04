from cython cimport address
from cython.operator cimport dereference as deref, preincrement as inc


## MesoscopicWorld
#  a python wrapper for Cpp_MesoscopicWorld
cdef class MesoscopicWorld:

    def __cinit__(self, edge_lengths = None,
        matrix_sizes = None, GSLRandomNumberGenerator rng = None):
        cdef string filename

        if edge_lengths is None:
            self.thisptr = new shared_ptr[Cpp_MesoscopicWorld](new Cpp_MesoscopicWorld())
        elif matrix_sizes is None:
            if isinstance(edge_lengths, Position3):
                self.thisptr = new shared_ptr[Cpp_MesoscopicWorld](
                    new Cpp_MesoscopicWorld(deref((<Position3>edge_lengths).thisptr)))
            else:
                filename = edge_lengths
                self.thisptr = new shared_ptr[Cpp_MesoscopicWorld](
                    new Cpp_MesoscopicWorld(filename))
        elif rng is None:
            self.thisptr = new shared_ptr[Cpp_MesoscopicWorld](
                new Cpp_MesoscopicWorld(
                    deref((<Position3>edge_lengths).thisptr),
                    deref((<Global>matrix_sizes).thisptr)))
        else:
            # XXX: GSLRandomNumberGenerator -> RandomNumberGenerator
            self.thisptr = new shared_ptr[Cpp_MesoscopicWorld](
                new Cpp_MesoscopicWorld(
                    deref((<Position3>edge_lengths).thisptr),
                    deref((<Global>matrix_sizes).thisptr), deref(rng.thisptr)))

    def __dealloc__(self):
        # XXX: Here, we release shared pointer,
        #      and if reference count to the MesoscopicWorld object,
        #      it will be released automatically.
        del self.thisptr

    def set_t(self, Real t):
        self.thisptr.get().set_t(t)

    def t(self):
        return self.thisptr.get().t()

    def edge_lengths(self):
        cdef Cpp_Position3 lengths = self.thisptr.get().edge_lengths()
        return Position3_from_Cpp_Position3(address(lengths))

    def volume(self):
        return self.thisptr.get().volume()

    def subvolume(self):
        return self.thisptr.get().subvolume()

    def num_molecules(self, Species sp, c = None):
        if c is None:
            return self.thisptr.get().num_molecules(deref(sp.thisptr))
        elif isinstance(c, Global):
            return self.thisptr.get().num_molecules(deref(sp.thisptr), deref((<Global>c).thisptr))
        else:
            return self.thisptr.get().num_molecules(deref(sp.thisptr), <Integer>c)

    def num_molecules_exact(self, Species sp, c = None):
        if c is None:
            return self.thisptr.get().num_molecules_exact(deref(sp.thisptr))
        elif isinstance(c, Global):
            return self.thisptr.get().num_molecules_exact(deref(sp.thisptr), deref((<Global>c).thisptr))
        else:
            return self.thisptr.get().num_molecules_exact(deref(sp.thisptr), <Integer>c)

    def add_molecules(self, Species sp, Integer num, c = None):
        if c is None:
            self.thisptr.get().add_molecules(deref(sp.thisptr), num)
        elif isinstance(c, Global):
            self.thisptr.get().add_molecules(deref(sp.thisptr), num, deref((<Global>c).thisptr))
        else:
            self.thisptr.get().add_molecules(deref(sp.thisptr), num, <Integer>c)

    def remove_molecules(self, Species sp, Integer num, c = None):
        if c is None:
            self.thisptr.get().remove_molecules(deref(sp.thisptr), num)
        elif isinstance(c, Global):
            self.thisptr.get().remove_molecules(deref(sp.thisptr), num, deref((<Global>c).thisptr))
        else:
            self.thisptr.get().remove_molecules(deref(sp.thisptr), num, <Integer>c)

    def list_species(self):
        cdef vector[Cpp_Species] species = self.thisptr.get().list_species()

        retval = []
        cdef vector[Cpp_Species].iterator it = species.begin()
        while it != species.end():
            retval.append(
                 Species_from_Cpp_Species(
                     <Cpp_Species*>(address(deref(it)))))
            inc(it)
        return retval

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

    def list_particles_exact(self, Species sp):
        cdef vector[pair[Cpp_ParticleID, Cpp_Particle]] particles
        particles = self.thisptr.get().list_particles_exact(deref(sp.thisptr))

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

    def save(self, string filename):
        self.thisptr.get().save(filename)

    def load(self, string filename):
        self.thisptr.get().load(filename)

    def bind_to(self, m):
        if isinstance(m, NetworkModel):
            self.thisptr.get().bind_to(
                <shared_ptr[Cpp_Model]>deref((<NetworkModel>m).thisptr))
        elif isinstance(m, NetfreeModel):
            self.thisptr.get().bind_to(
                <shared_ptr[Cpp_Model]>deref((<NetfreeModel>m).thisptr))
        else:
            raise ValueError, ("a wrong argument was given [%s]." % (type(m))
                + " the argument must be NetworkModel or NetfreeModel")

    def rng(self):
        return GSLRandomNumberGenerator_from_Cpp_RandomNumberGenerator(
            self.thisptr.get().rng())

cdef MesoscopicWorld MesoscopicWorld_from_Cpp_MesoscopicWorld(
    shared_ptr[Cpp_MesoscopicWorld] w):
    r = MesoscopicWorld(Position3(1, 1, 1), 1, 1, 1)
    r.thisptr.swap(w)
    return r

## MesoscopicSimulator
#  a python wrapper for Cpp_MesoscopicSimulator
cdef class MesoscopicSimulator:

    def __cinit__(self, m, MesoscopicWorld w):
        if isinstance(m, NetworkModel):
            self.thisptr = new Cpp_MesoscopicSimulator(
                <shared_ptr[Cpp_Model]>deref((<NetworkModel>m).thisptr),
                deref(w.thisptr))
        elif isinstance(m, NetfreeModel):
            self.thisptr = new Cpp_MesoscopicSimulator(
                <shared_ptr[Cpp_Model]>deref((<NetfreeModel>m).thisptr),
                deref(w.thisptr))
        else:
            raise ValueError, ("a wrong argument was given [%s]." % (type(m))
                + " the first argument must be NetworkModel or NetfreeModel")

    def __dealloc__(self):
        del self.thisptr

    def num_steps(self):
        return self.thisptr.num_steps()

    def step(self, upto = None):
        if upto is None:
            self.thisptr.step()
        else:
            return self.thisptr.step(<Real> upto)

    def t(self):
        return self.thisptr.t()

    def dt(self):
        return self.thisptr.dt()

    def next_time(self):
        return self.thisptr.next_time()

    def last_reactions(self):
        cdef vector[Cpp_ReactionRule] reactions = self.thisptr.last_reactions()
        cdef vector[Cpp_ReactionRule].iterator it = reactions.begin()
        retval = []
        while it != reactions.end():
            retval.append(ReactionRule_from_Cpp_ReactionRule(
                <Cpp_ReactionRule*>(address(deref(it)))))
            inc(it)
        return retval

    def set_t(self, Real new_t):
        self.thisptr.set_t(new_t)

    def set_dt(self, Real dt):
        self.thisptr.set_dt(dt)

    def initialize(self):
        self.thisptr.initialize()

    def model(self):
        return Model_from_Cpp_Model(self.thisptr.model())

    def world(self):
        return MesoscopicWorld_from_Cpp_MesoscopicWorld(self.thisptr.world())

    def run(self, Real duration, observers=None):
        cdef vector[shared_ptr[Cpp_Observer]] tmp

        if observers is None:
            self.thisptr.run(duration)
        else:
            for obs in observers:
                tmp.push_back(deref((<Observer>(obs.as_base())).thisptr))
            self.thisptr.run(duration, tmp)
