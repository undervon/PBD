SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE transaction_pack AS
    e_invalid_quantity EXCEPTION;
    
    PROCEDURE transaction_assigned_courses(v_employee_email IN employees.email%TYPE, 
    v_course_name IN courses.name%TYPE,
    v_certificate_name IN certificates.name%TYPE);
    
    PROCEDURE read_all_assigned_courses;
END transaction_pack;
/

CREATE OR REPLACE PACKAGE BODY transaction_pack AS
    e_invalid_certificate EXCEPTION;

    PROCEDURE check_existing_certificate (
        v_employee_id IN employee_certificate.employees_id%TYPE,
        v_certificate_id IN employee_certificate.certificates_id%TYPE
        )
    IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM employee_certificate 
        WHERE employees_id = v_employee_id AND certificates_id = v_certificate_id;
        
        IF v_count = 0 THEN
            RAISE e_invalid_certificate;
        END IF;
    END check_existing_certificate;
    
    PROCEDURE create_assigned_courses(
        v_assigned_date IN assigned_courses.assigned_date%TYPE,
        v_completed IN assigned_courses.completed%TYPE,
        v_employees_id IN assigned_courses.employees_id%TYPE,
        v_courses_id IN assigned_courses.courses_id%TYPE
        )
    IS
    BEGIN
        INSERT INTO assigned_courses(assigned_date, completed, employees_id, courses_id) 
        VALUES (v_assigned_date, v_completed, v_employees_id, v_courses_id);
    END create_assigned_courses;

    PROCEDURE transaction_assigned_courses(
        v_employee_email IN employees.email%TYPE, 
        v_course_name IN courses.name%TYPE,
        v_certificate_name IN certificates.name%TYPE
        )
    IS
        v_employee_id employees.id%TYPE;
        v_course_id courses.id%TYPE;
        v_certificate_id certificates.id%TYPE;
        v_quantity courses.quantity%TYPE;
        v_new_quantity courses.quantity%TYPE;
    BEGIN
        SET TRANSACTION NAME 'assigned_course_to_employee';
        
        v_employee_id := crud_employees_pack.read_employee_by_email(v_employee_email);
        v_course_id := crud_courses_pack.read_course_by_name(v_course_name);
        v_certificate_id := crud_certificates_pack.read_certificate_by_name(v_certificate_name);
        v_quantity := crud_courses_pack.read_course_quantity_by_id(v_course_id);
        v_new_quantity := v_quantity - 1;
        
        -- Change course quantity in courses table
        crud_courses_pack.update_couse_quantity_by_id(v_course_id, v_new_quantity);
        
        -- Check if the certificate exists in employee_certificate table
        check_existing_certificate(v_employee_id, v_certificate_id);
        
        -- Create new row in assigned_courses table
        create_assigned_courses(TO_DATE(SYSDATE, 'DD/MM/YYYY'), 'F', v_employee_id, v_course_id);
        
        -- Delete from the employee_certificate table, the row after id_employee and id_certificate
        crud_employee_certificate_pack.delete_employee_certificate_by_employee_id_and_certificates_id(v_employee_id, v_certificate_id);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Tranzactie reusita!');
        DBMS_OUTPUT.PUT_LINE('');
    EXCEPTION
        WHEN e_invalid_quantity THEN
            DBMS_OUTPUT.PUT_LINE('Tranzactie esuata! Cantitate 0');
            DBMS_OUTPUT.PUT_LINE('');
            ROLLBACK;
        WHEN e_invalid_certificate THEN
            DBMS_OUTPUT.PUT_LINE('Tranzactie esuata! Certificat inexistent');
            DBMS_OUTPUT.PUT_LINE('');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Tranzactie esuata! Problema nestiuta interceptata');
            DBMS_OUTPUT.PUT_LINE('');
            ROLLBACK;
    END transaction_assigned_courses;
    
    PROCEDURE read_all_assigned_courses
    IS
        v_assigned_courses_record assigned_courses%ROWTYPE;
        CURSOR c IS SELECT * FROM assigned_courses ORDER BY id ASC;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO v_assigned_courses_record.id, v_assigned_courses_record.assigned_date, v_assigned_courses_record.completed, 
            v_assigned_courses_record.employees_id, v_assigned_courses_record.courses_id;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_assigned_courses_record.id 
            || ' | ASSIGNED_DATE: ' || v_assigned_courses_record.assigned_date
            || ' | COMPLETED: ' || v_assigned_courses_record.completed
            || ' | EMPLOYEES_ID: ' || v_assigned_courses_record.employees_id
            || ' | COURSES_ID: ' || v_assigned_courses_record.courses_id);
        END LOOP;
        CLOSE c;
    END read_all_assigned_courses;
END transaction_pack;