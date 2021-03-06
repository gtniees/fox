undefine(`index')dnl
undefine(`len')dnl
undefine(`format')dnl
include(`m_dom_exception.m4')dnl
include(`m_dom_treewalk.m4')`'dnl
module m_dom_utils

  use fox_m_fsys_array_str, only: str_vs, vs_str
  use fox_m_fsys_format, only: operator(//)
  use m_common_attrs, only: getValue
  use m_common_element, only: element_t, attribute_t, &
    get_attlist_size, get_attribute_declaration, express_attribute_declaration
  use m_common_struct, only: xml_doc_state

  ! Public interfaces
  use m_dom_dom, only: DOMConfiguration, NamedNodeMap, Node,     &
    NodeList,                                                                  &
    ATTRIBUTE_NODE, CDATA_SECTION_NODE, COMMENT_NODE, DOCUMENT_NODE,           &
    DOCUMENT_TYPE_NODE, ELEMENT_NODE, ENTITY_REFERENCE_NODE,                   &
    PROCESSING_INSTRUCTION_NODE, TEXT_NODE,                                    &
    getAttributes, getChildNodes, getData, getDomConfig, getEntities,          &
    getFirstChild, getFoX_checks, getLength, getLocalName, getName,            &
    getNamespaceURI, getNextSibling, getNodeName, getNodeType, getNotationName,&
    getNotations, getOwnerDocument, getOwnerElement, getParameter,             &
    getParentNode, getPrefix, getPublicId, getSpecified, getSystemId,          &
    getTagName, getTarget, getXmlStandalone, getXmlVersion, getValue,          &
    haschildnodes, item, normalizeDocument

  ! Private interfaces
  use m_dom_dom, only: getNamespaceNodes, getStringValue, getXds, namespaceFixup

  use m_dom_error, only: DOMException, inException, throw_exception,           &
    getExceptionCode,                                                          &
    NAMESPACE_ERR, SERIALIZE_ERR, FoX_INTERNAL_ERROR, FoX_INVALID_NODE

  use FoX_wxml, only: xmlf_t,                                                  &
    xml_AddAttribute, xml_AddCharacters, xml_AddComment, xml_AddElementToDTD,  &
    xml_AddEntityReference, xml_AddExternalEntity, xml_AddInternalEntity,      &
    xml_AddDOCTYPE, xml_AddNotation, xml_AddXMLDeclaration, xml_AddXMLPI,      &
    xml_EndElement, xml_Close, xml_DeclareNamespace, xml_NewElement,           &
    xml_OpenFile, xml_UndeclareNamespace, xml_AddAttlistToDTD

  implicit none

  public :: dumpTree
  public :: serialize

  private

contains

  subroutine dumpTree(startNode)

    type(Node), pointer :: startNode   

    integer           :: indent_level

    indent_level = 0

    call dump2(startNode)

  contains

    recursive subroutine dump2(input)
      type(Node), pointer :: input
      type(Node), pointer :: temp, np
      type(NamedNodeMap), pointer :: attrs
      type(NodeList), pointer :: nsnodes
      integer :: i
      temp => input
      do while(associated(temp))
         write(*,"(3a,i0)") repeat(" ", indent_level), &
                        getNodeName(temp), " of type ", &
                        getNodeType(temp)
         if (getNodeType(temp)==ELEMENT_NODE) then
           write(*,"(2a)") repeat(" ", indent_level), &
                        "  ATTRIBUTES:"
           attrs => getAttributes(temp)
           do i = 0, getLength(attrs) - 1
             np => item(attrs, i)
             write(*, "(2a)") repeat(" ", indent_level)//"  ", &
               getName(np)
           enddo
           write(*,"(2a)") repeat(" ", indent_level), &
                        "  IN-SCOPE NAMESPACES:"
           nsnodes => getNamespaceNodes(temp)
           do i = 0, getLength(nsnodes) - 1
             np => item(nsnodes, i)
             write(*,"(4a)") repeat(" ", indent_level)//"  ", &
               getPrefix(np), ':', &
               getNamespaceURI(np)
           enddo
         endif
         if (hasChildNodes(temp)) then
            indent_level = indent_level + 3
            call dump2(getFirstChild(temp))
            indent_level = indent_level - 3
         endif
         temp => getNextSibling(temp)
      enddo

    end subroutine dump2

  end subroutine dumpTree


  TOHW_subroutine(serialize, (startNode, name))
    type(Node), pointer :: startNode   
    character(len=*), intent(in) :: name

    type(Node), pointer :: doc
    type(xmlf_t)  :: xf
    integer :: iostat
    logical :: xmlDecl

    if (getNodeType(startNode)/=DOCUMENT_NODE &
      .and.getNodeType(startNode)/=ELEMENT_NODE) then
      TOHW_m_dom_throw_error(FoX_INVALID_NODE)
    endif

    
    if (getNodeType(startNode)==DOCUMENT_NODE) then
      doc => startNode
      if (getParameter(getDomConfig(doc), "canonical-form") &
        .and.getXmlVersion(doc)=="1.1") then
        TOHW_m_dom_throw_error(SERIALIZE_ERR)
      endif
      call normalizeDocument(startNode, ex)
      if (present(ex)) then
        ! Only possible error should be namespace error ...
        if (getExceptionCode(ex)/=NAMESPACE_ERR) then
          TOHW_m_dom_throw_error(FoX_INTERNAL_ERROR)
        else
          TOHW_m_dom_throw_error(SERIALIZE_ERR)
        endif
      endif
    else
      doc => getOwnerDocument(startNode)
      ! We need to do this namespace fixup or serialization will fail.
      ! it doesn't change the semantics of the docs, but other
      ! normalization would, so we done here
      ! But only normalize if this is not a DOM level 1 node.
      if (getLocalName(startNode)/="" &
        .and.getParameter(getDomConfig(doc), "namespaces")) &
        call namespaceFixup(startNode, .true.)
    endif
    xmlDecl = getParameter(getDomConfig(doc), "xml-declaration")

    ! FIXME we shouldnt really normalize the Document here
    ! (except for namespace Normalization) but rather just
    ! pay attention to the DOMConfig values

    call xml_OpenFile(name, xf, iostat=iostat, unit=-1, &
      pretty_print=getParameter(getDomConfig(doc), "format-pretty-print"), &
      canonical=getParameter(getDomConfig(doc), "canonical-form"), &
      warning=.false., addDecl=.false.)
    if (iostat/=0) then
      TOHW_m_dom_throw_error(SERIALIZE_ERR)
    endif

    if (xmlDecl) then
      if (getXmlStandalone(doc)) then
        call xml_AddXMLDeclaration(xf, version=getXmlVersion(doc), standalone=.true.)
      else
        call xml_AddXMLDeclaration(xf, version=getXmlVersion(doc))
      endif
    endif

    call iter_dmp_xml(xf, startNode, ex)
    call xml_Close(xf)

  end subroutine serialize

  TOHW_subroutine(iter_dmp_xml, (xf, arg))
    type(xmlf_t), intent(inout) :: xf

    type(Node), pointer :: this, arg, treeroot 
    type(Node), pointer :: doc, attrchild, np
    type(NamedNodeMap), pointer :: nnm
    type(DOMConfiguration), pointer :: dc
    type(xml_doc_state), pointer :: xds
    type(element_t), pointer :: elem
    type(attribute_t), pointer :: att_decl
    integer :: i_tree, j, k
    logical :: doneChildren, doneAttributes
    character, pointer :: attrvalue(:), tmp(:)

    if (getNodeType(arg)==DOCUMENT_NODE) then
      doc => arg
    else
      doc => getOwnerDocument(arg)
    endif
    dc => getDomConfig(doc)
    xds => getXds(doc)

    treeroot => arg
TOHW_m_dom_treewalk(`dnl
    select case(getNodeType(this))
    case (ELEMENT_NODE)
      nnm => getAttributes(this)
      do j = 0, getLength(nnm) - 1
        attrchild => item(nnm, j)
        if (getLocalName(attrchild)=="xmlns") then
          if (len(getValue(attrchild))==0) then
            call xml_UndeclareNamespace(xf)
          else
            call xml_DeclareNamespace(xf, getValue(attrchild))
          endif
        elseif (getPrefix(attrchild)=="xmlns") then
          if (len(getValue(attrchild))==0) then
            call xml_UndeclareNamespace(xf, getLocalName(attrchild))
          else
            call xml_DeclareNamespace(xf, getValue(attrchild), &
              getLocalName(attrchild))
          endif
        endif
      enddo
      call xml_NewElement(xf, getTagName(this))
    case (ATTRIBUTE_NODE)
      if ((.not.getParameter(dc, "discard-default-content") &
        .or.getSpecified(this)) &
        ! only output it if it is not a default, or we are outputting defaults
        .and. (getPrefix(this)/="xmlns".and.getLocalName(this)/="xmlns")) then
        ! and we dont output NS declarations here.
        ! complex loop below is because we might have to worry about entrefs 
        ! being preserved in the attvalue. If we dont, we only go through the loop once anyway.
        allocate(attrvalue(0))
        do j = 0, getLength(getChildNodes(this)) - 1
          attrchild => item(getChildNodes(this), j)
          if (getNodeType(attrchild)==TEXT_NODE) then
            tmp => attrvalue
            allocate(attrvalue(size(tmp)+getLength(attrchild)))
            attrvalue(:size(tmp)) = tmp
            attrvalue(size(tmp)+1:) = vs_str(getData(attrChild))
            deallocate(tmp)
          elseif (getNodeType(attrchild)==ENTITY_REFERENCE_NODE) then
            tmp => attrvalue
            allocate(attrvalue(size(tmp)+len(getNodeName(attrchild))+2))
            attrvalue(:size(tmp)) = tmp
            attrvalue(size(tmp)+1:) = vs_str("&"//getData(attrChild)//";")
            deallocate(tmp)
          else
            TOHW_m_dom_throw_error(FoX_INTERNAL_ERROR)
          endif
        enddo
        call xml_AddAttribute(xf, getName(this), str_vs(attrvalue))
        deallocate(attrvalue)
      endif
      doneChildren = .true.
    case (TEXT_NODE)
      call xml_AddCharacters(xf, getData(this))
    case (CDATA_SECTION_NODE)
      if (getParameter(getDomConfig(doc), "canonical-form")) then
        call xml_AddCharacters(xf, getData(this))
      else
        call xml_AddCharacters(xf, getData(this), parsed = .false.)
      endif
    case (ENTITY_REFERENCE_NODE)
      if (.not.getParameter(getDomConfig(doc), "canonical-form")) then
        call xml_AddEntityReference(xf, getNodeName(this))
        doneChildren = .true.
      endif
    case (PROCESSING_INSTRUCTION_NODE)
      call xml_AddXMLPI(xf, getTarget(this), getData(this))
    case (COMMENT_NODE)
      if (.not.getParameter(getDomConfig(doc), "comments")) then
        call xml_AddComment(xf, getData(this))
      endif
    case (DOCUMENT_TYPE_NODE)
      if (.not.getParameter(getDomConfig(doc), "canonical-form")) then
        call xml_AddDOCTYPE(xf, getName(this))
        nnm => getNotations(this)
        do j = 0, getLength(nnm)-1
          np => item(nnm, j)
          if (getSystemId(np)=="") then
            call xml_AddNotation(xf, getNodeName(np), public=getPublicId(np))
          elseif (getPublicId(np)=="") then
            call xml_AddNotation(xf, getNodeName(np), system=getSystemId(np))
          else
            call xml_AddNotation(xf, getNodeName(np), system=getSystemId(np), &
              public=getPublicId(np))
          endif
        enddo
        nnm => getEntities(this)
        do j = 0, getLength(nnm)-1
          np => item(nnm, j)
          if (getSystemId(np)=="") then
            call xml_AddInternalEntity(xf, getNodeName(np), getStringValue(np))
          elseif (getPublicId(np)=="".and.getNotationName(np)=="") then
            call xml_AddExternalEntity(xf, getNodeName(np), system=getSystemId(np))
          elseif (getNotationName(np)=="") then
            call xml_AddExternalEntity(xf, getNodeName(np), system=getSystemId(np), &
              public=getPublicId(np))
          elseif (getPublicId(np)=="") then
            call xml_AddExternalEntity(xf, getNodeName(np), system=getSystemId(np), &
              notation=getNotationName(np))
          else
            call xml_AddExternalEntity(xf, getNodeName(np), system=getSystemId(np), &
              public=getPublicId(np), notation=getNotationName(np))
          endif
        enddo
        do j = 1, size(xds%element_list%list)
          elem => xds%element_list%list(j)
          if (associated(elem%model)) &
            call xml_AddElementToDTD(xf, str_vs(elem%name), str_vs(elem%model))
            ! Because we may have some undeclared but referenced elements
          do k = 1, get_attlist_size(elem)
            att_decl => get_attribute_declaration(elem, k)
            call xml_AddAttlistToDTD(xf, str_vs(elem%name), &
              express_attribute_declaration(att_decl))
          enddo
        enddo
      endif
    end select
'`',`
    if (getNodeType(this)==ELEMENT_NODE) then
      call xml_EndElement(xf, getTagName(this))
    endif
'`')

  end subroutine iter_dmp_xml

end module m_dom_utils
