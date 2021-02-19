*&---------------------------------------------------------------------*
*& Report zmgr_xml2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zmgr_xml2.

PARAMETERS : p_ex_xml RADIOBUTTON GROUP rb1.
PARAMETERS : p_im_xml RADIOBUTTON GROUP rb1.

IF p_ex_xml = 'X'.

  DATA lv_xml TYPE xstring.
  DATA lo_dom TYPE REF TO if_ixml_document.
  DATA it_itab TYPE STANDARD TABLE OF zmgr_tab_xml.

  SELECT * FROM zmgr_tab_xml INTO TABLE it_itab UP TO 10 ROWS.

  CALL TRANSFORMATION id SOURCE data_node = it_itab RESULT XML lv_xml.

  CALL FUNCTION 'SDIXML_XML_TO_DOM'
    EXPORTING
      xml           = lv_xml
    IMPORTING
      document      = lo_dom
    EXCEPTIONS
      invalid_input = 1
      OTHERS        = 2.

  IF sy-subrc = 0.
    CALL FUNCTION 'SDIXML_DOM_TO_SCREEN'
      EXPORTING
        document    = lo_dom
        title       = 'XML-Doc'
        encoding    = 'UTF-8'
      EXCEPTIONS
        no_document = 1
        OTHERS      = 2.

    IF sy-subrc = 0.

    ENDIF.
  ENDIF.


ELSEIF p_im_xml = 'X'.

  DATA xmlbin_tab TYPE TABLE OF x255.
  DATA xml_xstr TYPE xstring.
  DATA len TYPE i.
  DATA l_str_xml TYPE zmgr_tab_xml.


  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = 'C:\Users\mgr\Desktop\temp.xml'
      filetype                = 'BIN'
    IMPORTING
      filelength              = len
    TABLES
      data_tab                = xmlbin_tab
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = len
    IMPORTING
      buffer       = xml_xstr
    TABLES
      binary_tab   = xmlbin_tab
    EXCEPTIONS
      failed       = 1.

  DATA: BEGIN OF itab OCCURS 0,
          id_producers TYPE char10,
          name         TYPE char10,
          email        TYPE char10,
          city         TYPE char10,
          country      TYPE char10,
          phone        TYPE char10,
          postal_code  TYPE char10,
        END OF itab.


  CALL TRANSFORMATION zmgr_strans2
    SOURCE XML xml_xstr
    RESULT data_tab = itab[].

  IF sy-subrc <> 0.
    MESSAGE 'XML is wrong : ( ' TYPE 'E'.

  ELSE.

    LOOP AT itab[] INTO l_str_xml.
      INSERT zmgr_tab_xml FROM l_str_xml.
    ENDLOOP.

  ENDIF.


ELSE.

ENDIF.