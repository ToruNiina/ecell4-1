from libcpp.string cimport string
from libcpp cimport bool

# XXX Tomplorary using cython stl support.
#        Perhaps, we should consider importing std::pair by ourselves
#        that don't cast c-objects into python objects automatically.
from libcpp.pair cimport pair
from libcpp.vector cimport vector

from types cimport *
from multiset cimport multiset
from shared_ptr cimport shared_ptr


cdef extern from "gsl/gsl_rng.h":
    ctypedef struct gsl_rng:
        pass

## Cpp_GSLRandomNumberGenerator
#  ecell4::GSLRandomNumberGenerator
cdef extern from "ecell4/core/RandomNumberGenerator.hpp" namespace "ecell4":
    cdef cppclass Cpp_RandomNumberGenerator "ecell4::RandomNumberGenerator":
        # RandomNumberGenerator(shared_ptr[gsl_rng]) except +
        Cpp_RandomNumberGenerator() except +
        Real uniform(Real, Real)
        Integer uniform_int(Integer, Integer)
        Real gaussian(Real, Real)
        Integer binomial(Real, Integer)
        void seed(Integer)
        void seed()

    cdef cppclass Cpp_GSLRandomNumberGenerator "ecell4::GSLRandomNumberGenerator":
        # GSLRandomNumberGenerator(shared_ptr[gsl_rng]) except +
        Cpp_GSLRandomNumberGenerator() except +
        Real uniform(Real, Real)
        Integer uniform_int(Integer, Integer)
        Real gaussian(Real, Real)
        void seed(Integer)
        void seed()

## RandomNumberGenerator
#  a python wrapper for Cpp_GSLRandomNumberGenerator
cdef class GSLRandomNumberGenerator:
    # cdef Cpp_GSLRandomNumberGenerator* thisptr
    # cdef shared_ptr[Cpp_GSLRandomNumberGenerator]* thisptr
    cdef shared_ptr[Cpp_RandomNumberGenerator]* thisptr

cdef GSLRandomNumberGenerator GSLRandomNumberGenerator_from_Cpp_RandomNumberGenerator(
    shared_ptr[Cpp_RandomNumberGenerator])

## Cpp_UnitSpecies
#  ecell4::UnitSpecies
cdef extern from "ecell4/core/UnitSpecies.hpp" namespace "ecell4":
    cdef cppclass Cpp_UnitSpecies "ecell4::UnitSpecies":
        Cpp_UnitSpecies() except +
        Cpp_UnitSpecies(string) except +
        Cpp_UnitSpecies(Cpp_UnitSpecies&) except+
        bool operator==(Cpp_UnitSpecies& rhs)
        bool operator<(Cpp_UnitSpecies& rhs)
        bool operator>(Cpp_UnitSpecies& rhs)
        string serial()
        string name()
        void deserialize(string) except+
        bool add_site(string, string, string)

## UnitSpecies
#  a python wrapper for Cpp_UnitSpecies
cdef class UnitSpecies:
    cdef Cpp_UnitSpecies* thisptr

cdef UnitSpecies UnitSpecies_from_Cpp_UnitSpecies(Cpp_UnitSpecies *sp)

## Cpp_Species
#  ecell4::Species
cdef extern from "ecell4/core/Species.hpp" namespace "ecell4":
    cdef cppclass Cpp_Species "ecell4::Species":
        Cpp_Species() except +
        Cpp_Species(string) except +
        Cpp_Species(string, string) except +
        Cpp_Species(string, string, string) except +
        Cpp_Species(Cpp_Species&) except+
        bool operator==(Cpp_Species& rhs)
        bool operator<(Cpp_Species& rhs)
        bool operator>(Cpp_Species& rhs)
        string serial() # string == serial_type
        string get_attribute(string)
        # bool match(Cpp_Species&)
        void set_attribute(string, string)
        void remove_attribute(string)
        bool has_attribute(string)
        vector[pair[string, string]] list_attributes()
        # Integer get_unit(Cpp_UnitSpecies)
        void add_unit(Cpp_UnitSpecies)
        Integer num_units()
        void deserialize(string) except+

## Species
#  a python wrapper for Cpp_Species
cdef class Species:
    cdef Cpp_Species* thisptr

cdef Species Species_from_Cpp_Species(Cpp_Species *sp)

## Cpp_ReactionRule
#  ecell4::ReactionRule
cdef extern from "ecell4/core/ReactionRule.hpp" namespace "ecell4":
    cdef cppclass Cpp_ReactionRule "ecell4::ReactionRule":
        Cpp_ReactionRule() except +
        Cpp_ReactionRule(Cpp_ReactionRule&) except +
        Real k()
        vector[Cpp_Species]& reactants()
        vector[Cpp_Species]& products()
        # multiset[Cpp_Species]& reactants()
        # multiset[Cpp_Species]& products()
        void set_k(Real)
        void add_reactant(Cpp_Species)
        void add_product(Cpp_Species)
        string as_string()

## ReactionRule
#  a python wrapper for Cpp_ReactionRule
cdef class ReactionRule:
    cdef Cpp_ReactionRule* thisptr

cdef ReactionRule ReactionRule_from_Cpp_ReactionRule(Cpp_ReactionRule *rr)

## Cpp_CompartmentSpaceVectorImpl
#  ecell4::CompartmentSpaceVectorImpl
cdef extern from "ecell4/core/CompartmentSpace.hpp" namespace "ecell4":
    cdef cppclass Cpp_CompartmentSpaceVectorImpl "ecell4::CompartmentSpaceVectorImpl":
        Cpp_CompartmentSpaceVectorImpl(Cpp_Position3&) except+
        Real volume()
        Integer num_molecules(Cpp_Species &sp)
        vector[Cpp_Species] list_species()
        void set_edge_lengths(Cpp_Position3&)
        Cpp_Position3 edge_lengths()
        void set_volume(Real)
        void add_molecules(Cpp_Species &sp, Integer num)
        void remove_molecules(Cpp_Species &sp, Integer num)

## CompartmentSpaceVectorImpl
#  a python wrapper for Cpp_CompartmentSpaceVectorImpl
cdef class CompartmentSpaceVectorImpl:
    cdef Cpp_CompartmentSpaceVectorImpl* thisptr

## Cpp_ParticleSpaceVectorImpl
#  ecell4::ParticleSpaceVectorImpl
cdef extern from "ecell4/core/ParticleSpace.hpp" namespace "ecell4":
    cdef cppclass Cpp_ParticleSpaceVectorImpl "ecell4::ParticleSpaceVectorImpl":
        Cpp_ParticleSpaceVectorImpl(Cpp_Position3&) except+
        Cpp_Position3 edge_lengths()
        Integer num_particles()
        Integer num_particles(Cpp_Species&)
        vector[pair[Cpp_ParticleID, Cpp_Particle]] list_particles()
        vector[pair[Cpp_ParticleID, Cpp_Particle]] list_particles(Cpp_Species &sp)
        bool has_particle(Cpp_ParticleID &pid)

        bool update_particle(Cpp_ParticleID, Cpp_Particle)
        pair[Cpp_ParticleID, Cpp_Particle] get_particle(Cpp_ParticleID &pid)
        void remove_particle(Cpp_ParticleID &pid)
        vector[pair[pair[Cpp_ParticleID, Cpp_Particle], Real] ] list_particles_within_radius(
                Cpp_Position3 &pos, Real &radius)
        vector[pair[pair[Cpp_ParticleID, Cpp_Particle], Real] ] list_particles_within_radius(
                Cpp_Position3 &pos, Real &radius, Cpp_ParticleID &ignore)
        vector[pair[pair[Cpp_ParticleID, Cpp_Particle], Real] ] list_particles_within_radius(
                Cpp_Position3 &pos, Real &radius, Cpp_ParticleID &ignore1, Cpp_ParticleID &ignore2)


## ParticleSpaceVectorImpl
#  a python wrapper for ParticleSpaceVectorImpl
cdef class ParticleSpaceVectorImpl:
    cdef Cpp_ParticleSpaceVectorImpl* thisptr

## Cpp_Model
#  ecell4::Model
cdef extern from "ecell4/core/Model.hpp" namespace "ecell4":
    cdef cppclass Cpp_Model "ecell4::Model":
        Cpp_Model() except +
        void add_species_attribute(Cpp_Species sp)
        bool has_species_attribute(Cpp_Species sp)
        void remove_species_attribute(Cpp_Species sp)
        void add_reaction_rule(Cpp_ReactionRule)
        void remove_reaction_rule(Cpp_ReactionRule)
        bool has_reaction_rule(Cpp_ReactionRule)
        Cpp_Species apply_species_attributes(Cpp_Species& sp)
        vector[Cpp_ReactionRule] query_reaction_rules(Cpp_Species sp)
        vector[Cpp_ReactionRule] query_reaction_rules(
            Cpp_Species sp, Cpp_Species sp)

        # vector[Cpp_Species] list_species()
        # Cpp_Species create_species(string name)
        # Integer num_reaction_rules()
        # vector[Cpp_ReactionRule] reaction_rules()
        # vector[Cpp_Species] species_attributes()

## Model
#  a python wrapper for Cpp_Model, but wrapped by shared_ptr
cdef class Model:
    # cdef Cpp_Model* thisptr
    cdef shared_ptr[Cpp_Model]* thisptr

cdef Model Model_from_Cpp_Model(shared_ptr[Cpp_Model] m)

## Cpp_NetworkModel
#  ecell4::NetworkModel
cdef extern from "ecell4/core/NetworkModel.hpp" namespace "ecell4":
    cdef cppclass Cpp_NetworkModel "ecell4::NetworkModel":
        Cpp_NetworkModel() except +
        void add_species_attribute(Cpp_Species sp)
        bool has_species_attribute(Cpp_Species sp)
        void remove_species_attribute(Cpp_Species sp)
        void add_reaction_rule(Cpp_ReactionRule)
        void remove_reaction_rule(Cpp_ReactionRule)
        bool has_reaction_rule(Cpp_ReactionRule)
        Integer num_reaction_rules()
        Cpp_Species apply_species_attributes(Cpp_Species& sp)
        Cpp_Species create_species(string name)
        vector[Cpp_Species] list_species()
        vector[Cpp_ReactionRule] query_reaction_rules(Cpp_Species sp)
        vector[Cpp_ReactionRule] query_reaction_rules(
            Cpp_Species sp, Cpp_Species sp)
        vector[Cpp_ReactionRule] reaction_rules()
        vector[Cpp_Species] species_attributes()

## NetworkModel
#  a python wrapper for Cpp_NetowrkModel, but wrapped by shared_ptr
cdef class NetworkModel:
    # cdef Cpp_NetworkModel* thisptr
    cdef shared_ptr[Cpp_NetworkModel]* thisptr

cdef NetworkModel NetworkModel_from_Cpp_NetworkModel(
    shared_ptr[Cpp_NetworkModel] m)

## Cpp_NetfreeModel
#  ecell4::NetfreeModel
cdef extern from "ecell4/core/NetfreeModel.hpp" namespace "ecell4":
    cdef cppclass Cpp_NetfreeModel "ecell4::NetfreeModel":
        Cpp_NetfreeModel() except +
        void add_species_attribute(Cpp_Species sp)
        bool has_species_attribute(Cpp_Species sp)
        void remove_species_attribute(Cpp_Species sp)
        void add_reaction_rule(Cpp_ReactionRule)
        void remove_reaction_rule(Cpp_ReactionRule)
        bool has_reaction_rule(Cpp_ReactionRule)
        Integer num_reaction_rules()
        Cpp_Species apply_species_attributes(Cpp_Species& sp)
        Cpp_Species create_species(string name)
        vector[Cpp_Species] list_species()
        vector[Cpp_ReactionRule] query_reaction_rules(Cpp_Species sp)
        vector[Cpp_ReactionRule] query_reaction_rules(
            Cpp_Species sp, Cpp_Species sp)
        vector[Cpp_ReactionRule] reaction_rules()
        vector[Cpp_Species] species_attributes()

## NetfreeModel
#  a python wrapper for Cpp_NetfreeModel, but wrapped by shared_ptr
cdef class NetfreeModel:
    # cdef Cpp_NetfreeModel* thisptr
    cdef shared_ptr[Cpp_NetfreeModel]* thisptr

cdef NetfreeModel NetfreeModel_from_Cpp_NetfreeModel(
    shared_ptr[Cpp_NetfreeModel] m)

## Cpp_Position3
#  ecell4::Position3
cdef extern from "ecell4/core/Position3.hpp" namespace "ecell4":
    cdef cppclass Cpp_Position3 "ecell4::Position3":
        Cpp_Position3() except +
        Cpp_Position3(Real, Real, Real) except +
        Cpp_Position3(Cpp_Position3 &rhs) except+

    Cpp_Position3 operator+(Cpp_Position3, Cpp_Position3)
    Cpp_Position3 operator-(Cpp_Position3, Cpp_Position3)
    Cpp_Position3 operator/(Cpp_Position3, Real)
    Cpp_Position3 operator*(Cpp_Position3, Real)
    Real& operator[](Integer)

## Position3
#  a python wrapper for Cpp_Position3
cdef class Position3:
    cdef Cpp_Position3* thisptr

cdef Position3 Position3_from_Cpp_Position3(Cpp_Position3 *p)

## Cpp_ParticleID
#  ecell4::ParticleID
cdef extern from "ecell4/core/Identifier.hpp" namespace "ecell4":
    ctypedef int lot_type
    ctypedef unsigned long long serial_type
    ctypedef pair[int, unsigned long long] value_type

    cdef cppclass Cpp_ParticleID "ecell4::ParticleID":
        Cpp_ParticleID() except+
        Cpp_ParticleID(value_type) except+
        Cpp_ParticleID(Cpp_ParticleID& rhs) except+
        Cpp_ParticleID log_add(lot_type& rhs)
        Cpp_ParticleID log_subtract(lot_type& rhs)
        Cpp_ParticleID& lot_advance(lot_type& rhs)
        Cpp_ParticleID& lot_retraace(lot_type& rhs)
        Cpp_ParticleID serial_add(serial_type& rhs)
        Cpp_ParticleID serial_subtract(serial_type& rhs)
        Cpp_ParticleID& serial_advance(serial_type& rhs)
        Cpp_ParticleID& serial_retrace(serial_type& rhs)
        # Cpp_ParticleID &operator=(Cpp_ParticleID& rhs) # XXX not yet suppoted
        bool operator==(Cpp_ParticleID& rhs)
        bool operator!=(Cpp_ParticleID& rhs)
        bool operator<(Cpp_ParticleID& rhs)
        bool operator>=(Cpp_ParticleID& rhs)
        bool operator>(Cpp_ParticleID& rhs)
        bool operator<=(Cpp_ParticleID& rhs)
        # operator value_type()
        value_type& operator() ()
        int& lot()
        unsigned long long& serial()

cdef class ParticleID:
    cdef Cpp_ParticleID* thisptr

cdef ParticleID ParticleID_from_Cpp_ParticleID(Cpp_ParticleID* p)

## Cpp_Particle
#  ecell4::Particle
cdef extern from "ecell4/core/Particle.hpp" namespace "ecell4":
    cdef cppclass Cpp_Particle "ecell4::Particle":
        Cpp_Particle() except +
        Cpp_Particle(Cpp_Species, Cpp_Position3, Real radius, Real D) except +
        Cpp_Particle(Cpp_Particle &rhs) except+
        Cpp_Position3 position()
        Real radius()
        Real D()
        Cpp_Species &species()

## Particle
#  a python wrapper for Cpp_Particle
cdef class Particle:
    cdef Cpp_Particle* thisptr

cdef Particle Particle_from_Cpp_Particle(Cpp_Particle* p)

## Cpp_Voxel
#  ecell4::Voxel
ctypedef int Coord

cdef extern from "ecell4/core/Voxel.hpp" namespace "ecell4":
    cdef cppclass Cpp_Voxel "ecell4::Voxel":
        Cpp_Voxel() except +
        Cpp_Voxel(Cpp_Species, Coord, Real radius, Real D) except +
        Cpp_Voxel(Cpp_Voxel &rhs) except+
        Coord coordinate()
        Real D()
        Real radius()
        Cpp_Species &species()

## Voxel
#  a python wrapper for Cpp_Voxel
cdef class Voxel:
    cdef Cpp_Voxel* thisptr

cdef Voxel Voxel_from_Cpp_Voxel(Cpp_Voxel* p)
