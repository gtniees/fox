dnl
include(`foreach.m4')`'dnl
dnl
include(`common.m4')`'dnl
dnl
dnl Below we only use arguments with a type of xsd:string
define(`TOHWM4_moleculeargs', `(dictRef,convention,title,id,ref,formula,chirality,role)')dnl
dnl
define(`TOHWM4_moleculeargslist', `dnl
m4_foreach(`x', TOHWM4_moleculeargs, `,x')dnl
')dnl
dnl
define(`TOHWM4_moleculeargsdecl',`dnl
m4_foreach(`x',TOHWM4_moleculeargs,`TOHWM4_dummyargdecl(x)')
')dnl
define(`TOHWM4_moleculeargsuse',`dnl
m4_foreach(`x',TOHWM4_moleculeargs,`TOHWM4_dummyarguse(x)')
')dnl
define(`TOHWM4_dlpolymoleculecheck',`dnl
    if (present(style)) then
      if (style=="DL_POLY") then
        if (present(atomRefs).or.present(occupancies).or.present(atomIds).or.present(fmt)) &
          call FoX_error("With DL_POLY style, no optional arguments permitted.")
        call addDlpolyMatrix(xf, $1, elements)
        return
      endif
    endif
')dnl
dnl
define(`TOHWM4_writeatom', `
    do i = 1, natoms
      call xml_NewElement(xf, "atom")
      call xml_AddAttribute(xf, "elementType", trim(elements(i)))
      call cmlAddCoords(xf, coords=$1, style=style, fmt=fmt)
      if (present(occupancies)) call xml_AddAttribute(xf, "occupancy", occupancies(i))
      if (present(atomRefs)) call xml_AddAttribute(xf, "ref", atomRefs(i))
      if (present(atomIds)) call xml_AddAttribute(xf, "id", atomIds(i))
      call xml_EndElement(xf, "atom")
     enddo
')dnl
dnl
define(`TOHWM4_writeparticle', `
    do i = 1, natoms
      call xml_NewElement(xf, "particle")
      if (present(elements)) call xml_AddAttribute(xf, "elementType", trim(elements(i)))
      call cmlAddCoords(xf, coords=$1, style=style, fmt=fmt)
      if (present(occupancies)) call xml_AddAttribute(xf, "occupancy", occupancies(i))
      if (present(atomRefs)) call xml_AddAttribute(xf, "ref", atomRefs(i))
      if (present(atomIds)) call xml_AddAttribute(xf, "id", atomIds(i))
      call xml_EndElement(xf, "particle")
     enddo
')dnl
define(`TOHWM4_molecule_subs', ``'dnl
  subroutine cmlAddMolecule$1(xf, elements, atomRefs, coords, occupancies, atomIds, style, fmt &
TOHWM4_moleculeargslist)
    type(xmlf_t), intent(inout) :: xf
    real(kind=$1), intent(in)              :: coords(:, :)
    character(len=*), intent(in)           :: elements(:)
    character(len=*), intent(in), optional :: atomRefs(:) 
    real(kind=$1), intent(in), optional :: occupancies(:)
    character(len=*), intent(in), optional :: atomIds(:)
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

TOHWM4_moleculeargsdecl

#ifndef DUMMYLIB

    call cmlStartMolecule(xf &
TOHWM4_moleculeargslist)
    call cmlAddAtoms(xf, elements, atomRefs, coords, occupancies, atomIds, style, fmt)
    call cmlEndMolecule(xf)

#endif DUMMYLIB

  end subroutine cmlAddMolecule$1


  subroutine cmlAddMolecule$1_sh(xf, natoms, elements, atomRefs, coords, occupancies, atomIds, style, fmt &
TOHWM4_moleculeargslist)
    type(xmlf_t), intent(inout) :: xf
    integer, intent(in) :: natoms
    real(kind=$1), intent(in)              :: coords(3, natoms)
    character(len=*), intent(in)           :: elements(natoms)
    character(len=*), intent(in), optional :: atomRefs(natoms) 
    real(kind=$1), intent(in), optional :: occupancies(natoms) 
    character(len=*), intent(in), optional :: atomIds(natoms) 
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

TOHWM4_moleculeargsdecl

#ifndef DUMMYLIB
    call cmlStartMolecule(xf &
TOHWM4_moleculeargslist)
    call cmlAddAtoms(xf, natoms, elements, atomRefs, coords, occupancies, atomIds, style, fmt)
    call cmlEndMolecule(xf)
#endif

  end subroutine cmlAddMolecule$1_sh


  subroutine cmlAddMolecule_3_$1(xf, elements, x, y, z, atomRefs, occupancies, atomIds, style, fmt &
TOHWM4_moleculeargslist)
    type(xmlf_t), intent(inout) :: xf
    real(kind=$1), intent(in)              :: x(:)
    real(kind=$1), intent(in)              :: y(:)
    real(kind=$1), intent(in)              :: z(:)
    character(len=*), intent(in)           :: elements(:)
    character(len=*), intent(in), optional :: atomRefs(:) 
    character(len=*), intent(in), optional :: atomIds(:) 
    real(kind=$1), intent(in), optional :: occupancies(:) 
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

TOHWM4_moleculeargsdecl

#ifndef DUMMYLIB
    call cmlStartMolecule(xf &
TOHWM4_moleculeargslist)
    call cmlAddAtoms(xf, elements, x, y, z, atomRefs, occupancies, atomIds, style, fmt)
    call cmlEndMolecule(xf)
#endif

  end subroutine cmlAddMolecule_3_$1


  subroutine cmlAddMolecule_3_$1_sh(xf, natoms, elements, x, y, z, atomRefs, occupancies, atomIds, style, fmt &
TOHWM4_moleculeargslist)
    type(xmlf_t), intent(inout) :: xf
    integer, intent(in) :: natoms
    real(kind=$1), intent(in)              :: x(natoms)
    real(kind=$1), intent(in)              :: y(natoms)
    real(kind=$1), intent(in)              :: z(natoms)
    character(len=*), intent(in)           :: elements(natoms)
    character(len=*), intent(in), optional :: atomRefs(natoms)
    character(len=*), intent(in), optional :: atomIds(natoms)
    real(kind=$1), intent(in), optional :: occupancies(natoms)
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

TOHWM4_moleculeargsdecl

#ifndef DUMMYLIB
    call cmlStartMolecule(xf &
TOHWM4_moleculeargslist)
    call cmlAddAtoms(xf, natoms, elements, x, y, z, atomRefs, occupancies, atomIds, style, fmt)
    call cmlEndMolecule(xf)
#endif

  end subroutine cmlAddMolecule_3_$1_sh

  subroutine cmlAddAtoms$1(xf, elements, atomRefs, coords, occupancies, atomIds, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    real(kind=$1), intent(in)              :: coords(:, :)
    character(len=*), intent(in)           :: elements(:)
    character(len=*), intent(in), optional :: atomRefs(:) 
    real(kind=$1), intent(in), optional :: occupancies(:)
    character(len=*), intent(in), optional :: atomIds(:)
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

#ifndef DUMMYLIB
    integer          :: i, natoms

TOHWM4_dlpolymoleculecheck(`coords')`'

    call xml_NewElement(xf, "atomArray")

    natoms = size(coords,2)
TOHWM4_writeatom(`coords(:,i)')`'

    call xml_EndElement(xf, "atomArray")
#endif

  end subroutine cmlAddAtoms$1

  subroutine cmlAddAtoms$1_sh(xf, natoms, elements, atomRefs, coords, occupancies, atomIds, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    integer, intent(in) :: natoms
    real(kind=$1), intent(in)              :: coords(3, natoms)
    character(len=*), intent(in)           :: elements(natoms)
    character(len=*), intent(in), optional :: atomRefs(natoms) 
    real(kind=$1), intent(in), optional :: occupancies(natoms) 
    character(len=*), intent(in), optional :: atomIds(natoms) 
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

#ifndef DUMMYLIB
    integer          :: i

TOHWM4_dlpolymoleculecheck(`coords(:,:natoms)')`'

    call xml_NewElement(xf, "atomArray")

TOHWM4_writeatom(`coords(:,i)')`'

    call xml_EndElement(xf, "atomArray")
#endif

  end subroutine cmlAddAtoms$1_sh

  subroutine cmlAddAtoms_3_$1(xf, elements, x, y, z, atomRefs, occupancies, atomIds, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    real(kind=$1), intent(in)              :: x(:)
    real(kind=$1), intent(in)              :: y(:)
    real(kind=$1), intent(in)              :: z(:)
    character(len=*), intent(in)           :: elements(:)
    character(len=*), intent(in), optional :: atomRefs(:) 
    character(len=*), intent(in), optional :: atomIds(:) 
    real(kind=$1), intent(in), optional :: occupancies(:) 
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

#ifndef DUMMYLIB
    integer          :: i, natoms

TOHWM4_dlpolymoleculecheck(`x, y, z')`'

    call xml_NewElement(xf, "atomArray")

    natoms = size(x)
TOHWM4_writeatom(`(/x(i),y(i),z(i)/)')`'

    call xml_EndElement(xf, "atomArray")

#endif

  end subroutine cmlAddAtoms_3_$1

  subroutine cmlAddAtoms_3_$1_sh(xf, natoms, elements, x, y, z, atomRefs, occupancies, atomIds, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    integer, intent(in) :: natoms
    real(kind=$1), intent(in)              :: x(natoms)
    real(kind=$1), intent(in)              :: y(natoms)
    real(kind=$1), intent(in)              :: z(natoms)
    character(len=*), intent(in)           :: elements(natoms)
    character(len=*), intent(in), optional :: atomRefs(natoms)
    character(len=*), intent(in), optional :: atomIds(natoms)
    real(kind=$1), intent(in), optional :: occupancies(natoms)
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

#ifndef DUMMYLIB
    integer          :: i

TOHWM4_dlpolymoleculecheck(`x(:natoms), y(:natoms), z(:natoms)')`'

    call xml_NewElement(xf, "atomArray")

TOHWM4_writeatom(`(/x(i),y(i),z(i)/)')`'

    call xml_EndElement(xf, "atomArray")
#endif

  end subroutine cmlAddAtoms_3_$1_sh

  subroutine cmlAddParticles$1(xf, elements, atomRefs, coords, occupancies, atomIds, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    real(kind=$1), intent(in)              :: coords(:, :)
    character(len=*), intent(in), optional :: elements(:)
    character(len=*), intent(in), optional :: atomRefs(:) 
    real(kind=$1), intent(in), optional :: occupancies(:)
    character(len=*), intent(in), optional :: atomIds(:)
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

#ifndef DUMMYLIB
    integer          :: i, natoms

TOHWM4_dlpolymoleculecheck(`coords')`'

    call xml_NewElement(xf, "atomArray")

    natoms = size(coords,2)
TOHWM4_writeparticle(`coords(:,i)')`'

    call xml_EndElement(xf, "atomArray")
#endif

  end subroutine cmlAddParticles$1

  subroutine cmlAddParticles$1_sh(xf, natoms, elements, atomRefs, coords, occupancies, atomIds, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    integer, intent(in) :: natoms
    real(kind=$1), intent(in)              :: coords(3, natoms)
    character(len=*), intent(in), optional :: elements(natoms)
    character(len=*), intent(in), optional :: atomRefs(natoms) 
    real(kind=$1), intent(in), optional :: occupancies(natoms) 
    character(len=*), intent(in), optional :: atomIds(natoms) 
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

#ifndef DUMMYLIB
    integer          :: i

TOHWM4_dlpolymoleculecheck(`coords(:,:natoms)')`'

    call xml_NewElement(xf, "atomArray")

TOHWM4_writeparticle(`coords(:,i)')`'

    call xml_EndElement(xf, "atomArray")
#endif

  end subroutine cmlAddParticles$1_sh

  subroutine cmlAddParticles_3_$1(xf, elements, x, y, z, atomRefs, occupancies, atomIds, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    real(kind=$1), intent(in)              :: x(:)
    real(kind=$1), intent(in)              :: y(:)
    real(kind=$1), intent(in)              :: z(:)
    character(len=*), intent(in), optional :: elements(:)
    character(len=*), intent(in), optional :: atomRefs(:) 
    character(len=*), intent(in), optional :: atomIds(:) 
    real(kind=$1), intent(in), optional :: occupancies(:) 
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

#ifndef DUMMYLIB
    integer          :: i, natoms

TOHWM4_dlpolymoleculecheck(`x, y, z')`'

    call xml_NewElement(xf, "atomArray")

    natoms = size(x)
TOHWM4_writeparticle(`(/x(i),y(i),z(i)/)')`'

    call xml_EndElement(xf, "atomArray")

#endif

  end subroutine cmlAddParticles_3_$1

  subroutine cmlAddParticles_3_$1_sh(xf, natoms, elements, x, y, z, atomRefs, occupancies, atomIds, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    integer, intent(in) :: natoms
    real(kind=$1), intent(in)              :: x(natoms)
    real(kind=$1), intent(in)              :: y(natoms)
    real(kind=$1), intent(in)              :: z(natoms)
    character(len=*), intent(in), optional :: elements(natoms)
    character(len=*), intent(in), optional :: atomRefs(natoms)
    character(len=*), intent(in), optional :: atomIds(natoms)
    real(kind=$1), intent(in), optional :: occupancies(natoms)
    character(len=*), intent(in), optional :: fmt
    character(len=*), intent(in), optional :: style

#ifndef DUMMYLIB
    integer          :: i

TOHWM4_dlpolymoleculecheck(`x(:natoms), y(:natoms), z(:natoms)')`'

    call xml_NewElement(xf, "atomArray")

TOHWM4_writeparticle(`(/x(i),y(i),z(i)/)')`'

    call xml_EndElement(xf, "atomArray")
#endif

  end subroutine cmlAddParticles_3_$1_sh

#ifndef DUMMYLIB

  subroutine cmlAddCoords_$1(xf, coords, style, fmt)
    type(xmlf_t), intent(inout) :: xf
    real(kind=$1), intent(in), dimension(:) :: coords
    character(len=*), intent(in), optional  :: style
    character(len=*), intent(in), optional  :: fmt

    if (present(style)) then
      select case(style)
      case ("x3") 
        call addcoords_x3_$1(xf, coords, fmt)
      case ("cartesian") 
        call addcoords_x3_$1(xf, coords, fmt)
      case ("xFrac")
        call addcoords_xfrac_$1(xf, coords, fmt)
      case ("fractional")
        call addcoords_xfrac_$1(xf, coords, fmt)
      case ("xyz3")
        call addcoords_xyz3_$1(xf, coords, fmt)
      case ("xyzFrac")
        call addcoords_xyzfrac_$1(xf, coords, fmt)
      case default
        call FoX_error("Invalid style specification for atomic coordinates")
      end select
    else
      call addcoords_x3_$1(xf, coords, fmt)
    endif

  end subroutine cmlAddCoords_$1

  subroutine addcoords_xyz3_$1(xf, coords, fmt)
    type(xmlf_t), intent(inout)              :: xf
    real(kind=$1), intent(in), dimension(:) :: coords
    character(len=*), intent(in), optional   :: fmt

    select case (size(coords))
    case (2)
      call xml_AddAttribute(xf, "xy2", coords,fmt)
    case(3)
      call xml_AddAttribute(xf, "xyz3", coords,fmt)
    end select

  end subroutine addcoords_xyz3_$1


  subroutine addcoords_xyzfrac_$1(xf, coords, fmt)
    type(xmlf_t), intent(inout)             :: xf
    real(kind=$1), intent(in), dimension(:) :: coords
    character(len=*), intent(in), optional  :: fmt

    select case (size(coords))
    case (2)
      call xml_AddAttribute(xf, "xyFract", coords, fmt)
    case(3)
      call xml_AddAttribute(xf, "xyzFract", coords, fmt)
    end select

  end subroutine addcoords_xyzfrac_$1


  subroutine addcoords_x3_$1(xf, coords, fmt)
    type(xmlf_t), intent(inout)            :: xf
    real(kind=$1), intent(in), dimension(:):: coords
    character(len=*), intent(in), optional :: fmt

    select case(size(coords))
    case(2)
      call xml_AddAttribute(xf, "x2", coords(1), fmt)
      call xml_AddAttribute(xf, "y2", coords(2), fmt)
    case(3)
      call xml_AddAttribute(xf, "x3", coords(1), fmt)
      call xml_AddAttribute(xf, "y3", coords(2), fmt)
      call xml_AddAttribute(xf, "z3", coords(3), fmt)
    end select

  end subroutine addcoords_x3_$1


  subroutine addcoords_xfrac_$1(xf, coords, fmt)
    type(xmlf_t), intent(inout)             :: xf
    real(kind=$1), intent(in), dimension(:) :: coords
    character(len=*), intent(in), optional  :: fmt

    call xml_AddAttribute(xf, "xFract", coords(1), fmt)
    call xml_AddAttribute(xf, "yFract", coords(2), fmt)
    call xml_AddAttribute(xf, "zFract", coords(3), fmt)

  end subroutine addcoords_xfrac_$1

  subroutine addDlpolyMatrix_$1(xf, coords, elems)
    type(xmlf_t), intent(inout)                :: xf
    real(kind=$1), intent(in), dimension(:, :) :: coords
    character(len=2), intent(in), dimension(:) :: elems

    integer :: natoms, i

    natoms = size(elems)
    
    call xml_NewElement(xf, "matrix")
    call xml_AddAttribute(xf, "nrows", size(elems))
    call xml_AddAttribute(xf, "ncols", 11)
    call xml_AddAttribute(xf, "dataType", "xsd:string")
    
    call xml_AddNewline(xf)
    do i = 1, natoms
      call xml_AddCharacters(xf, elems(i)//"  "//str(i))
      call xml_AddNewline(xf)
      call xml_AddCharacters(xf, str(coords(1,i))//" "//str(coords(2,i))//" "//str(coords(3,i)))
      call xml_AddNewline(xf)
      call xml_AddCharacters(xf, "0 0 0")
      call xml_AddNewline(xf)
      call xml_AddCharacters(xf, "0 0 0")
      call xml_AddNewline(xf)
    enddo
    call xml_EndElement(xf, "matrix")
  end subroutine addDlpolyMatrix_$1

  subroutine addDlpolyMatrix_3_$1(xf, x, y, z, elems)
    type(xmlf_t), intent(inout)                :: xf
    real(kind=$1), intent(in), dimension(:)    :: x, y, z
    character(len=2), intent(in), dimension(:) :: elems

    integer :: natoms, i

    natoms = size(elems)
    
    call xml_NewElement(xf, "matrix")
    call xml_AddAttribute(xf, "nrows", size(elems))
    call xml_AddAttribute(xf, "ncols", 11)
    call xml_AddAttribute(xf, "dataType", "xsd:string")
    
    call xml_AddNewline(xf)
    do i = 1, natoms
      call xml_AddCharacters(xf, elems(i)//"  "//str(i))
      call xml_AddNewline(xf)
      call xml_AddCharacters(xf, str(x(i))//" "//str(y(i))//" "//str(z(i)))
      call xml_AddNewline(xf)
      call xml_AddCharacters(xf, "0 0 0")
      call xml_AddNewline(xf)
      call xml_AddCharacters(xf, "0 0 0")
      call xml_AddNewline(xf)
    enddo
    call xml_EndElement(xf, "matrix")
  end subroutine addDlpolyMatrix_3_$1
#endif

')dnl
dnl
! This file is AUTOGENERATED
! To change, edit m_wcml_molecule.m4 and regenerate

module m_wcml_molecule

  use fox_m_fsys_realtypes, only: sp, dp
  use FoX_wxml, only: xmlf_t

#ifndef DUMMYLIB
  use fox_m_fsys_format, only: str
  use m_common_error, only: FoX_error
  use FoX_wxml, only: xml_NewElement, xml_EndElement
  use FoX_wxml, only: xml_AddAttribute, xml_AddCharacters, xml_AddNewline

! Fix for pgi, requires this explicitly:
  use m_wxml_overloads
#endif

  implicit none
  private

  interface cmlAddMolecule
    module procedure cmlAddMoleculeSP
    module procedure cmlAddMoleculeSP_sh
    module procedure cmlAddMolecule_3_SP
    module procedure cmlAddMolecule_3_SP_sh
    module procedure cmlAddMoleculeDP
    module procedure cmlAddMoleculeDP_sh
    module procedure cmlAddMolecule_3_DP
    module procedure cmlAddMolecule_3_DP_sh
  end interface

  interface cmlAddAtoms
    module procedure cmlAddAtomsSP
    module procedure cmlAddAtomsSP_sh
    module procedure cmlAddAtoms_3_SP
    module procedure cmlAddAtoms_3_SP_sh
    module procedure cmlAddAtomsDP
    module procedure cmlAddAtomsDP_sh
    module procedure cmlAddAtoms_3_DP
    module procedure cmlAddAtoms_3_DP_sh
  end interface

  interface cmlAddParticles
    module procedure cmlAddParticlesSP
    module procedure cmlAddParticlesSP_sh
    module procedure cmlAddParticles_3_SP
    module procedure cmlAddParticles_3_SP_sh
    module procedure cmlAddParticlesDP
    module procedure cmlAddParticlesDP_sh
    module procedure cmlAddParticles_3_DP
    module procedure cmlAddParticles_3_DP_sh
  end interface

#ifndef DUMMYLIB
  interface cmlAddCoords
    module procedure cmlAddCoords_sp
    module procedure cmlAddCoords_dp
  end interface

  interface addDlpolyMatrix
    module procedure addDlpolyMatrix_sp
    module procedure addDlpolyMatrix_3_sp
    module procedure addDlpolyMatrix_dp
    module procedure addDlpolyMatrix_3_dp
  end interface
#endif

  public :: cmlStartMolecule
  public :: cmlEndMolecule

  public :: cmlAddAtoms
  public :: cmlAddParticles

  public :: cmlAddMolecule

contains

  subroutine cmlStartMolecule(xf &
TOHWM4_moleculeargslist)
    type(xmlf_t), intent(inout) :: xf

TOHWM4_moleculeargsdecl

#ifndef DUMMYLIB
    
    call xml_NewElement(xf, "molecule")

TOHWM4_moleculeargsuse

#endif
  end subroutine cmlStartMolecule

  subroutine cmlEndMolecule(xf)
    type(xmlf_t), intent(inout) :: xf

#ifndef DUMMYLIB
    call xml_EndElement(xf, "molecule")
#endif
  end subroutine cmlEndMolecule

TOHWM4_molecule_subs(`sp')

TOHWM4_molecule_subs(`dp')

end module m_wcml_molecule
