SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE crud_employee_certificate_pack AS
    PROCEDURE create_employee_certificate (v_employees_email IN employees.email%TYPE, 
    v_certificates_name IN certificates.name%TYPE);

	PROCEDURE read_all_employee_certificate;

    PROCEDURE delete_employee_certificate_by_employee_id_and_certificates_id (v_employees_id IN employee_certificate.employees_id%TYPE, 
    v_certificates_id IN employee_certificate.certificates_id%TYPE);

    PROCEDURE delete_all_employee_certificate;
END crud_employee_certificate_pack;
/

CREATE OR REPLACE PACKAGE BODY crud_employee_certificate_pack AS
    PROCEDURE create_employee_certificate (
        v_employees_email IN employees.email%TYPE, 
        v_certificates_name IN certificates.name%TYPE
    )
    IS
    BEGIN
        INSERT INTO employee_certificate VALUES (crud_employees_pack.read_employee_by_email(v_employees_email),
        crud_certificates_pack.read_certificate_by_name(v_certificates_name));
    END create_employee_certificate;

	PROCEDURE read_all_employee_certificate
	IS
        v_employee_certificate_record employee_certificate%ROWTYPE;
        CURSOR c IS SELECT * FROM employee_certificate ORDER BY employees_id ASC;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO v_employee_certificate_record.employees_id, v_employee_certificate_record.certificates_id;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('EMPLOYEES_ID: ' || v_employee_certificate_record.employees_id
            || ' | CERTIFICATES_ID: ' || v_employee_certificate_record.certificates_id);
        END LOOP;
        CLOSE c;
	END read_all_employee_certificate;

    PROCEDURE delete_employee_certificate_by_employee_id_and_certificates_id (v_employees_id IN employee_certificate.employees_id%TYPE, 
    v_certificates_id IN employee_certificate.certificates_id%TYPE)
    IS
    BEGIN
        DELETE FROM employee_certificate WHERE employees_id = v_employees_id AND certificates_id = v_certificates_id;
    END delete_employee_certificate_by_employee_id_and_certificates_id;

    PROCEDURE delete_all_employee_certificate
    IS
    BEGIN
        DELETE FROM employee_certificate;
    END delete_all_employee_certificate;
END crud_employee_certificate_pack;