import collections
from cython.operator cimport dereference as deref, preincrement as inc
from cython cimport address
from libcpp.string cimport string
from libcpp.vector cimport vector

from ecell4.types cimport *
from ecell4.shared_ptr cimport shared_ptr
from ecell4.core cimport *

## ODEWorld
#  a python wrapper for Cpp_ODEWorld
cdef class ODEWorld:

    def __cinit__(self, edge_lengths = None):
        cdef string filename

        if edge_lengths is None:
            self.thisptr = new shared_ptr[Cpp_ODEWorld](new Cpp_ODEWorld())
        elif isinstance(edge_lengths, Real3):
            self.thisptr = new shared_ptr[Cpp_ODEWorld](
                new Cpp_ODEWorld(deref((<Real3>edge_lengths).thisptr)))
        else:
            filename = tostring(edge_lengths)
            self.thisptr = new shared_ptr[Cpp_ODEWorld](new Cpp_ODEWorld(filename))

    def __dealloc__(self):
        # XXX: Here, we release shared pointer,
        #      and if reference count to the ODEWorld object become zero,
        #      it will be released automatically.
        del self.thisptr

    def set_t(self, Real t):
        self.thisptr.get().set_t(t)

    def t(self):
        return self.thisptr.get().t()

    def edge_lengths(self):
        cdef Cpp_Real3 lengths = self.thisptr.get().edge_lengths()
        return Real3_from_Cpp_Real3(address(lengths))

    def volume(self):
        return self.thisptr.get().volume()

    def num_molecules(self, Species sp):
        return self.thisptr.get().num_molecules(deref(sp.thisptr))

    def num_molecules_exact(self, Species sp):
        return self.thisptr.get().num_molecules_exact(deref(sp.thisptr))

    def list_species(self):
        cdef vector[Cpp_Species] raw_list_species = self.thisptr.get().list_species()
        retval = []
        cdef vector[Cpp_Species].iterator it = raw_list_species.begin()
        while it != raw_list_species.end():
            retval.append(
                Species_from_Cpp_Species(<Cpp_Species*> (address(deref(it)))))
            inc(it)
        return retval

    def set_volume(self, Real vol):
        self.thisptr.get().set_volume(vol)

    def add_molecules(self, Species sp, Integer num, shape=None):
        if shape is None:
            self.thisptr.get().add_molecules(deref(sp.thisptr), num)
        else:
            self.thisptr.get().add_molecules(
                deref(sp.thisptr), num, deref((<Shape>(shape.as_base())).thisptr))

    def remove_molecules(self, Species sp, Integer num):
        self.thisptr.get().remove_molecules(deref(sp.thisptr), num)

    def get_value(self, Species sp):
        return self.thisptr.get().get_value(deref(sp.thisptr))

    def set_value(self, Species sp, Real num):
        self.thisptr.get().set_value(deref(sp.thisptr), num)

    def save(self, filename):
        self.thisptr.get().save(tostring(filename))

    def load(self, string filename):
        self.thisptr.get().load(tostring(filename))

    def has_species(self, Species sp):
        return self.thisptr.get().has_species(deref(sp.thisptr))

    def reserve_species(self, Species sp):
        self.thisptr.get().reserve_species(deref(sp.thisptr))

    def release_species(self, Species sp):
        self.thisptr.get().release_species(deref(sp.thisptr))

    def bind_to(self, m):
        self.thisptr.get().bind_to(deref(Cpp_Model_from_Model(m)))

    def as_base(self):
        retval = Space()
        del retval.thisptr
        retval.thisptr = new shared_ptr[Cpp_Space](
            <shared_ptr[Cpp_Space]>deref(self.thisptr))
        return retval

cdef ODEWorld ODEWorld_from_Cpp_ODEWorld(
    shared_ptr[Cpp_ODEWorld] w):
    r = ODEWorld(Real3(1, 1, 1))
    r.thisptr.swap(w)
    return r

## ODESimulator
#  a python wrapper for Cpp_ODESimulator
cdef class ODESimulator:

    def __cinit__(self, m, ODEWorld w=None):
        if w is None:
            self.thisptr = new Cpp_ODESimulator(
                deref((<ODEWorld>m).thisptr))
        else:
            self.thisptr = new Cpp_ODESimulator(
                deref(Cpp_Model_from_Model(m)), deref(w.thisptr))

    def __dealloc__(self):
        del self.thisptr

    def num_steps(self):
        return self.thisptr.num_steps()

    def next_time(self):
        return self.thisptr.next_time()

    def dt(self):
        return self.thisptr.dt()

    def step(self, upto = None):
        if upto is None:
            self.thisptr.step()
        else:
            return self.thisptr.step(upto)

    def t(self):
        return self.thisptr.t()

    def set_t(self, Real new_t):
        self.thisptr.set_t(new_t)

    def set_dt(self, Real dt):
        self.thisptr.set_dt(dt)

    def initialize(self):
        self.thisptr.initialize()

    def last_reactions(self):
        cdef vector[Cpp_ReactionRule] reactions = self.thisptr.last_reactions()
        cdef vector[Cpp_ReactionRule].iterator it = reactions.begin()
        retval = []
        while it != reactions.end():
            retval.append(ReactionRule_from_Cpp_ReactionRule(
                <Cpp_ReactionRule*>(address(deref(it)))))
            inc(it)
        return retval

    def model(self):
        return Model_from_Cpp_Model(self.thisptr.model())

    def world(self):
        return ODEWorld_from_Cpp_ODEWorld(self.thisptr.world())

    def run(self, Real duration, observers=None):
        cdef vector[shared_ptr[Cpp_Observer]] tmp

        if observers is None:
            self.thisptr.run(duration)
        elif isinstance(observers, collections.Iterable):
            for obs in observers:
                tmp.push_back(deref((<Observer>(obs.as_base())).thisptr))
            self.thisptr.run(duration, tmp)
        else:
            self.thisptr.run(duration,
                deref((<Observer>(observers.as_base())).thisptr))

cdef ODESimulator ODESimulator_from_Cpp_ODESimulator(Cpp_ODESimulator* s):
    r = ODESimulator(
        Model_from_Cpp_Model(s.model()),
        ODEWorld_from_Cpp_ODEWorld(s.world()))
    del r.thisptr
    r.thisptr = s
    return r

## ODEFactory
#  a python wrapper for Cpp_ODEFactory
cdef class ODEFactory:

    def __cinit__(self):
        self.thisptr = new Cpp_ODEFactory()

    def __dealloc__(self):
        del self.thisptr

    def create_world(self, arg1):
        if isinstance(arg1, Real3):
            return ODEWorld_from_Cpp_ODEWorld(
                shared_ptr[Cpp_ODEWorld](
                    self.thisptr.create_world(deref((<Real3>arg1).thisptr))))
        elif isinstance(arg1, str):
            return ODEWorld_from_Cpp_ODEWorld(
                shared_ptr[Cpp_ODEWorld](self.thisptr.create_world(<string>(arg1))))
        else:
            return ODEWorld_from_Cpp_ODEWorld(
                shared_ptr[Cpp_ODEWorld](self.thisptr.create_world(
                    deref(Cpp_Model_from_Model(arg1)))))

    def create_simulator(self, arg1, ODEWorld arg2=None):
        if arg2 is None:
            return ODESimulator_from_Cpp_ODESimulator(
                self.thisptr.create_simulator(deref((<ODEWorld>arg1).thisptr)))
        else:
            return ODESimulator_from_Cpp_ODESimulator(
                self.thisptr.create_simulator(
                    deref(Cpp_Model_from_Model(arg1)), deref(arg2.thisptr)))

cdef class ODERatelaw:
    # Abstract ODERatelaw Type.
    def __cinit__(self):
        self.thisptr = new shared_ptr[Cpp_ODERatelaw](
                <Cpp_ODERatelaw*>(new Cpp_ODERatelawMassAction(0.0)) )  # Dummy

    def __dealloc__(self):
        del self.thisptr

    def as_base(self):
        return self

cdef class ODERatelawMassAction:
    def __cinit__(self, Real k):
        self.thisptr = new shared_ptr[Cpp_ODERatelawMassAction](
                <Cpp_ODERatelawMassAction*>(new Cpp_ODERatelawMassAction(k)))

    def __dealloc__(self):
        del self.thisptr

    def is_available(self):
        return self.get().is_available
    def set_k(self, Real k):
        self.get().thisptr.set_k(k)
    def get_k(self):
        return self.get().thisptr.get_k()
    def as_base(self):
        base_type = ODERatelaw()
        del base_type.thisptr
        base_type.thisptr = new shared_ptr[Cpp_ODERatelaw](
                <shared_ptr[Cpp_ODERatelaw]>(deref(self.thisptr))
                )
        return base_type

cdef class ODEReactionRule:
    def __cinit__(self):
        self.thisptr = new Cpp_ODEReactionRule()

    def __dealloc__(self):
        del self.thisptr

    def k(self):
        return self.thisptr.k()
    def set_k(self, Real k):
        self.thisptr.set_k(k)
    def add_reactant(self, Species sp, Real coeff):
        self.thisptr.add_reactant(deref(sp.thisptr), coeff)
    def add_product(self, Species sp, Real coeff):
        self.thisptr.add_product(deref(sp.thisptr), coeff)
    def set_reactant_coefficient(self, Integer index, Real coeff):
        self.thisptr.set_reactant_coefficient(index, coeff)
    def set_product_coefficient(self, Integer index, Real coeff):
        self.thisptr.set_product_coefficient(index, coeff)

    def set_ratelaw(self, ratelaw_obj):
        pass
    def reactants(self):
        cdef vector[Cpp_Species] cpp_reactants = self.thisptr.reactants()
        retval = []
        cdef vector[Cpp_Species].iterator it = cpp_reactants.begin()
        while it != cpp_reactants.end():
            retval.append(
                    Species_from_Cpp_Species(<Cpp_Species*>address(deref(it))))
            inc(it)
        return retval

    def reactants_coefficients(self):
        cdef vector[Real] coefficients = self.thisptr.reactants_coefficients()
        retval = []
        cdef vector[Real].iterator it = coefficients.begin()
        while it != coefficients.end():
            retval.append( deref(it) )
            inc(it)
        return retval

    def products(self):
        cdef vector[Cpp_Species] cpp_products = self.thisptr.products()
        retval = []
        cdef vector[Cpp_Species].iterator it = cpp_products.begin()
        while it != cpp_products.end():
            retval.append(
                    Species_from_Cpp_Species(<Cpp_Species*>address(deref(it))))
            inc(it)
        return retval

    def products_coefficients(self):
        cdef vector[Real] coefficients = self.thisptr.products_coefficients()
        retval = []
        cdef vector[Real].iterator it = coefficients.begin()
        while it != coefficients.end():
            retval.append( deref(it) )
            inc(it)
        return retval

    def as_string(self):
        reactants = self.reactants()
        reactants_coeff = self.reactants_coefficients()
        products = self.products()
        products_coeff = self.products_coefficients()
        retval = ""
        first = True
        for (sp, coeff) in zip(reactants, reactants_coeff):
            s = "{0}({1})".format(coeff, sp.serial())
            if first == True:
                retval = s
                first = False
            else:
                retval = "{} + {}".format(retval, s)
        retval = retval + " ---> "
        first = True
        for (sp, coeff) in zip(products, products_coeff):
            s = "{0}({1})".format(coeff, sp.serial())
            if first == True:
                retval += s
                first = False
            else:
                retval = "{} + {}".format(retval, s)
        return retval

cdef ODEReactionRule ODEReactionRule_from_Cpp_ODEReactionRule(Cpp_ODEReactionRule *s):
    cdef Cpp_ODEReactionRule *new_obj = new Cpp_ODEReactionRule(deref(s))
    ret = ODEReactionRule()
    del ret.thisptr
    ret.thisptr = new_obj
    return ret

cdef class ODENetworkModel:
    #def __cinit__(self):
    #    self.thisptr = new shared_ptr[Cpp_ODENetworkModel](
    #        <Cpp_ODENetworkModel*>(new Cpp_ODENetworkModel()) )
    def __cinit__(self, NetworkModel m = None):
        if m == None:
            self.thisptr = new shared_ptr[Cpp_ODENetworkModel](
                <Cpp_ODENetworkModel*>(new Cpp_ODENetworkModel()) )
        else:
            self.thisptr = new shared_ptr[Cpp_ODENetworkModel](
                (<Cpp_ODENetworkModel*>(new Cpp_ODENetworkModel( deref(m.thisptr) ) )) )

    def __dealloc__(self):
        del self.thisptr
    def update_model(self):
        self.thisptr.get().update_model()
    def has_model(self):
        return self.thisptr.get().has_model()
    def ode_reaction_rules(self):
        cdef vector[Cpp_ODEReactionRule] cpp_rules = self.thisptr.get().ode_reaction_rules()
        retval = []
        cdef vector[Cpp_ODEReactionRule].iterator it = cpp_rules.begin()
        while it != cpp_rules.end():
            retval.append( ODEReactionRule_from_Cpp_ODEReactionRule(address(deref(it))) )
            inc(it)
        return retval
    def num_reaction_rules(self):
        return self.thisptr.get().num_reaction_rules()
    def add_reaction_rule(self, ODEReactionRule rr):
        self.thisptr.get().add_reaction_rule( deref(rr.thisptr) )

cdef class ODESimulator2:
    def __cinit__(self, ODENetworkModel m, ODEWorld w):
        self.thisptr = new Cpp_ODESimulator2(deref(m.thisptr), deref(w.thisptr)) 
    def __dealloc__(self):
        del self.thisptr
