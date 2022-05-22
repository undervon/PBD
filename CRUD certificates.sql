SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE crud_certificates_pack AS
    PROCEDURE create_certificate (v_name IN certificates.name%TYPE, 
    v_release_date IN certificates.release_date%TYPE, 
    v_availability IN certificates.availability%TYPE);
    
    PROCEDURE read_first_specified_certificates (v_no_certificates IN NUMBER);
    
    PROCEDURE read_all_certificates;
    
    PROCEDURE read_certificates_by_id (v_id IN certificates.id%TYPE);
    
    FUNCTION read_certificate_by_name (v_name certificates.name%TYPE) RETURN certificates.id%TYPE;
    
    PROCEDURE update_certificate_by_id (v_id IN certificates.id%TYPE,
    v_name certificates.name%TYPE,
    v_release_date certificates.release_date%TYPE,
    v_availability certificates.availability%TYPE);
    
    PROCEDURE delete_certificate_by_id (v_id IN certificates.id%TYPE);
    
    PROCEDURE delete_all_certificates;
END crud_certificates_pack;
/

CREATE OR REPLACE PACKAGE BODY crud_certificates_pack AS
    -- 1. CREATE CERTIFICATES
    PROCEDURE create_certificate (
        v_name IN certificates.name%TYPE, 
        v_release_date IN certificates.release_date%TYPE, 
        v_availability IN certificates.availability%TYPE
        )
    IS
    BEGIN
      INSERT INTO certificates(name, release_date, availability) VALUES (v_name, v_release_date, v_availability);
    END create_certificate;

    -- 2. READ CERTIFICATES
    PROCEDURE read_first_specified_certificates (v_no_certificates IN NUMBER)
    IS
        v_certificates_record certificates%ROWTYPE;
        CURSOR c IS SELECT * FROM certificates ORDER BY id ASC;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO v_certificates_record.id, v_certificates_record.name, v_certificates_record.release_date, v_certificates_record.availability;
            EXIT WHEN c%ROWCOUNT > v_no_certificates OR c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_certificates_record.id || ' | NAME: ' || v_certificates_record.name
            || ' | RELEASE_DATE: ' || v_certificates_record.release_date 
            || ' | AVAILABILITY: ' || v_certificates_record.availability);
        END LOOP;
        CLOSE c;
    END read_first_specified_certificates;

    PROCEDURE read_all_certificates
    IS
        v_certificates_record certificates%ROWTYPE;
        CURSOR c IS SELECT * FROM certificates ORDER BY id ASC;
    BEGIN
        OPEN c;
        LOOP
             FETCH c INTO v_certificates_record.id, v_certificates_record.name, v_certificates_record.release_date, v_certificates_record.availability;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_certificates_record.id || ' | NAME: ' || v_certificates_record.name
            || ' | RELEASE_DATE: ' || v_certificates_record.release_date 
            || ' | AVAILABILITY: ' || v_certificates_record.availability);
        END LOOP;
        CLOSE c;
    END read_all_certificates;

    PROCEDURE read_certificates_by_id (v_id IN certificates.id%TYPE)
    IS
        v_name certificates.name%TYPE;
        v_release_date certificates.release_date%TYPE;
        v_availability certificates.availability%TYPE;
    BEGIN
        SELECT name, release_date, availability INTO v_name, v_release_date, v_availability FROM certificates WHERE id = v_id;
            DBMS_OUTPUT.PUT_LINE('NAME: ' || v_name
            || ' | RELEASE_DATE: ' || v_release_date 
            || ' | AVAILABILITY: ' || v_availability);
--            
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Certificatul cu id-ul: ' || v_id || ' nu exista in DB');
    END read_certificates_by_id;

    FUNCTION read_certificate_by_name (v_name certificates.name%TYPE) RETURN certificates.id%TYPE
    IS
        v_id certificates.id%TYPE;
    BEGIN
        SELECT id INTO v_id FROM certificates WHERE name = v_name;
        RETURN (v_id);
    END read_certificate_by_name;

    -- 3. UPDATE CERTIFICATES
    PROCEDURE update_certificate_by_id (
        v_id IN certificates.id%TYPE,
        v_name certificates.name%TYPE,
        v_release_date certificates.release_date%TYPE,
        v_availability certificates.availability%TYPE
        )
    IS
    BEGIN
        UPDATE certificates SET name = v_name, release_date = v_release_date, availability = v_availability WHERE id = v_id;
    END update_certificate_by_id;

    -- 4. DELETE CERTIFICATES
    PROCEDURE delete_certificate_by_id (v_id IN certificates.id%TYPE)
    IS
    BEGIN
        DELETE FROM certificates WHERE id = v_id;
    END delete_certificate_by_id;

    PROCEDURE delete_all_certificates
    IS
    BEGIN
        DELETE FROM certificates;
    END delete_all_certificates;
END crud_certificates_pack;