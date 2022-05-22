-- Generated by Oracle SQL Developer Data Modeler 21.4.1.349.1605
--   at:        2022-05-12 00:25:56 EEST
--   site:      Oracle Database 11g
--   type:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE certificates (
    id           INTEGER NOT NULL,
    name         VARCHAR2(100) NOT NULL,
    release_date DATE NOT NULL,
    availability DATE NOT NULL
)
LOGGING;

ALTER TABLE certificates ADD CONSTRAINT certificates_pk PRIMARY KEY ( id );

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

CREATE TABLE courses (
    id       INTEGER NOT NULL,
    name     VARCHAR2(100) NOT NULL,
    duration INTEGER NOT NULL,
    quantity INTEGER NOT NULL
)
LOGGING;

ALTER TABLE courses ADD CONSTRAINT courses_pk PRIMARY KEY ( id );

CREATE OR REPLACE PACKAGE crud_courses_pack AS
    PROCEDURE create_course (v_name IN courses.name%TYPE, 
    v_duration IN courses.duration%TYPE, 
    v_quantity IN courses.quantity%TYPE);
    
    PROCEDURE read_first_specified_courses (v_no_courses IN NUMBER);
    
    PROCEDURE read_all_courses;
    
    PROCEDURE read_course_by_id (v_id IN courses.id%TYPE);
    
    FUNCTION read_course_by_name (v_name courses.name%TYPE) RETURN courses.id%TYPE;
    
	FUNCTION read_course_quantity_by_id(v_id courses.id%TYPE) RETURN courses.quantity%TYPE;
	
    PROCEDURE update_course_by_id (v_id IN courses.id%TYPE,
    v_name courses.name%TYPE,
    v_duration courses.duration%TYPE,
    v_quantity courses.quantity%TYPE);
	
	PROCEDURE update_couse_quantity_by_id(v_id IN courses.id%TYPE,
	v_quantity courses.quantity%TYPE);
    
    PROCEDURE delete_course_by_id (v_id IN courses.id%TYPE);
    
    PROCEDURE delete_all_courses;
END crud_courses_pack;
/

CREATE OR REPLACE PACKAGE crud_employee_certificate_pack AS
    PROCEDURE create_employee_certificate (v_employees_email IN employees.email%TYPE, 
    v_certificates_name IN certificates.name%TYPE);

	PROCEDURE read_all_employee_certificate;

    PROCEDURE delete_employee_certificate_by_employee_id_and_certificates_id (v_employees_id IN employee_certificate.employees_id%TYPE, 
    v_certificates_id IN employee_certificate.certificates_id%TYPE);

    PROCEDURE delete_all_employee_certificate;
END crud_employee_certificate_pack;
/

CREATE TABLE employees (
    id         INTEGER NOT NULL,
    email      VARCHAR2(100) NOT NULL,
    password   VARCHAR2(50) NOT NULL,
    department VARCHAR2(20) NOT NULL
)
LOGGING;

ALTER TABLE employees
    ADD CONSTRAINT email_ck CHECK ( REGEXP_LIKE ( email,
                                                  '[a-z0-9._%-]+@[a-z0-9._%-]+\.[a-z]{2,4}' ) );

ALTER TABLE employees ADD CONSTRAINT employees_pk PRIMARY KEY ( id );

ALTER TABLE employees ADD CONSTRAINT employees_email_un UNIQUE ( email );

CREATE OR REPLACE PACKAGE crud_employees_pack AS
    PROCEDURE create_employee (v_email IN employees.email%TYPE, 
    v_password IN employees.password%TYPE, 
    v_department IN employees.department%TYPE);
    
    PROCEDURE read_first_specified_employees (v_no_employees IN NUMBER);
    
    PROCEDURE read_all_employees;
    
    PROCEDURE read_employee_by_id (v_id IN employees.id%TYPE);
    
    FUNCTION read_employee_by_email (v_email employees.email%TYPE) RETURN employees.id%TYPE;
    
    PROCEDURE update_employee_by_id (v_id IN employees.id%TYPE,
    v_email employees.email%TYPE,
    v_password employees.password%TYPE,
    v_department employees.department%TYPE);
    
    PROCEDURE delete_employee_by_id (v_id IN employees.id%TYPE);
    
    PROCEDURE delete_all_employees;
END crud_employees_pack;
/

CREATE OR REPLACE PACKAGE transaction_pack AS
    e_invalid_quantity EXCEPTION;
    
    PROCEDURE transaction_assigned_courses(v_employee_email IN employees.email%TYPE, 
    v_course_name IN courses.name%TYPE,
    v_certificate_name IN certificates.name%TYPE);
    
    PROCEDURE read_all_assigned_courses;
END transaction_pack;
/

CREATE TABLE assigned_courses (
    id            INTEGER NOT NULL,
    assigned_date DATE NOT NULL,
    completed     CHAR(1) NOT NULL,
    employees_id  INTEGER NOT NULL,
    courses_id    INTEGER NOT NULL
)
LOGGING;

ALTER TABLE assigned_courses ADD CONSTRAINT assigned_courses_pk PRIMARY KEY ( id );

CREATE TABLE employee_certificate (
    employees_id    INTEGER NOT NULL,
    certificates_id INTEGER NOT NULL
)
LOGGING;

ALTER TABLE employee_certificate ADD CONSTRAINT employee_certificate_pk PRIMARY KEY ( employees_id,
                                                                                      certificates_id );

ALTER TABLE assigned_courses
    ADD CONSTRAINT a_c_courses_fk FOREIGN KEY ( courses_id )
        REFERENCES courses ( id )
    NOT DEFERRABLE;

ALTER TABLE assigned_courses
    ADD CONSTRAINT a_c_employees_fk FOREIGN KEY ( employees_id )
        REFERENCES employees ( id )
    NOT DEFERRABLE;

ALTER TABLE employee_certificate
    ADD CONSTRAINT e_c_certificates_fk FOREIGN KEY ( certificates_id )
        REFERENCES certificates ( id )
    NOT DEFERRABLE;

ALTER TABLE employee_certificate
    ADD CONSTRAINT e_c_employees_fk FOREIGN KEY ( employees_id )
        REFERENCES employees ( id )
    NOT DEFERRABLE;

CREATE OR REPLACE TRIGGER check_quantity 
    BEFORE INSERT OR UPDATE ON courses 
    FOR EACH ROW 
BEGIN
    IF :new.quantity < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Insert sau update esuat! Cantitate 0');
        RAISE transaction_pack.e_invalid_quantity;
    END IF;
END check_quantity; 
/

CREATE OR REPLACE PACKAGE BODY crud_certificates_pack AS
    -- 1. CREATE CERTIFICATES
    PROCEDURE create_certificate (
        v_name         IN certificates.name%TYPE,
        v_release_date IN certificates.release_date%TYPE,
        v_availability IN certificates.availability%TYPE
    ) IS
    BEGIN
        INSERT INTO certificates (
            name,
            release_date,
            availability
        ) VALUES (
            v_name,
            v_release_date,
            v_availability
        );

    END create_certificate;

    -- 2. READ CERTIFICATES
    PROCEDURE read_first_specified_certificates (
        v_no_certificates IN NUMBER
    ) IS
        v_certificates_record certificates%rowtype;
        CURSOR c IS
        SELECT
            *
        FROM
            certificates
        ORDER BY
            id ASC;

    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO
                v_certificates_record.id,
                v_certificates_record.name,
                v_certificates_record.release_date,
                v_certificates_record.availability;

            EXIT WHEN c%rowcount > v_no_certificates OR c%notfound;
            dbms_output.put_line('ID: '
                                 || v_certificates_record.id
                                 || ' | NAME: '
                                 || v_certificates_record.name
                                 || ' | RELEASE_DATE: '
                                 || v_certificates_record.release_date
                                 || ' | AVAILABILITY: '
                                 || v_certificates_record.availability);

        END LOOP;

        CLOSE c;
    END read_first_specified_certificates;

    PROCEDURE read_all_certificates IS
        v_certificates_record certificates%rowtype;
        CURSOR c IS
        SELECT
            *
        FROM
            certificates
        ORDER BY
            id ASC;

    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO
                v_certificates_record.id,
                v_certificates_record.name,
                v_certificates_record.release_date,
                v_certificates_record.availability;

            EXIT WHEN c%notfound;
            dbms_output.put_line('ID: '
                                 || v_certificates_record.id
                                 || ' | NAME: '
                                 || v_certificates_record.name
                                 || ' | RELEASE_DATE: '
                                 || v_certificates_record.release_date
                                 || ' | AVAILABILITY: '
                                 || v_certificates_record.availability);

        END LOOP;

        CLOSE c;
    END read_all_certificates;

    PROCEDURE read_certificates_by_id (
        v_id IN certificates.id%TYPE
    ) IS

        v_name         certificates.name%TYPE;
        v_release_date certificates.release_date%TYPE;
        v_availability certificates.availability%TYPE;
    BEGIN
        SELECT
            name,
            release_date,
            availability
        INTO
            v_name,
            v_release_date,
            v_availability
        FROM
            certificates
        WHERE
            id = v_id;

        dbms_output.put_line('NAME: '
                             || v_name
                             || ' | RELEASE_DATE: '
                             || v_release_date
                             || ' | AVAILABILITY: '
                             || v_availability);
--            
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('Certificatul cu id-ul: '
                                 || v_id
                                 || ' nu exista in DB');
    END read_certificates_by_id;

    FUNCTION read_certificate_by_name (
        v_name certificates.name%TYPE
    ) RETURN certificates.id%TYPE IS
        v_id certificates.id%TYPE;
    BEGIN
        SELECT
            id
        INTO v_id
        FROM
            certificates
        WHERE
            name = v_name;

        RETURN ( v_id );
    END read_certificate_by_name;

    -- 3. UPDATE CERTIFICATES
    PROCEDURE update_certificate_by_id (
        v_id           IN certificates.id%TYPE,
        v_name         certificates.name%TYPE,
        v_release_date certificates.release_date%TYPE,
        v_availability certificates.availability%TYPE
    ) IS
    BEGIN
        UPDATE certificates
        SET
            name = v_name,
            release_date = v_release_date,
            availability = v_availability
        WHERE
            id = v_id;

    END update_certificate_by_id;

    -- 4. DELETE CERTIFICATES
    PROCEDURE delete_certificate_by_id (
        v_id IN certificates.id%TYPE
    ) IS
    BEGIN
        DELETE FROM certificates
        WHERE
            id = v_id;

    END delete_certificate_by_id;

    PROCEDURE delete_all_certificates IS
    BEGIN
        DELETE FROM certificates;

    END delete_all_certificates;

END crud_certificates_pack;
/

CREATE OR REPLACE PACKAGE BODY crud_courses_pack AS
    -- 1. CREATE COURSES
    PROCEDURE create_course (
        v_name     IN courses.name%TYPE,
        v_duration IN courses.duration%TYPE,
        v_quantity IN courses.quantity%TYPE
    ) IS
    BEGIN
        INSERT INTO courses (
            name,
            duration,
            quantity
        ) VALUES (
            v_name,
            v_duration,
            v_quantity
        );

    END create_course;

    -- 2. READ COURSES
    PROCEDURE read_first_specified_courses (
        v_no_courses IN NUMBER
    ) IS
        v_courses_record courses%rowtype;
        CURSOR c IS
        SELECT
            *
        FROM
            courses
        ORDER BY
            id ASC;

    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO
                v_courses_record.id,
                v_courses_record.name,
                v_courses_record.duration,
                v_courses_record.quantity;

            EXIT WHEN c%rowcount > v_no_courses OR c%notfound;
            dbms_output.put_line('ID: '
                                 || v_courses_record.id
                                 || ' | NAME: '
                                 || v_courses_record.name
                                 || ' | DURATION: '
                                 || v_courses_record.duration
                                 || ' | QUANTITY: '
                                 || v_courses_record.quantity);

        END LOOP;

        CLOSE c;
    END read_first_specified_courses;

    PROCEDURE read_all_courses IS
        v_courses_record courses%rowtype;
        CURSOR c IS
        SELECT
            *
        FROM
            courses
        ORDER BY
            id ASC;

    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO
                v_courses_record.id,
                v_courses_record.name,
                v_courses_record.duration,
                v_courses_record.quantity;

            EXIT WHEN c%notfound;
            dbms_output.put_line('ID: '
                                 || v_courses_record.id
                                 || ' | NAME: '
                                 || v_courses_record.name
                                 || ' | DURATION: '
                                 || v_courses_record.duration
                                 || ' | QUANTITY: '
                                 || v_courses_record.quantity);

        END LOOP;

        CLOSE c;
    END read_all_courses;

    PROCEDURE read_course_by_id (
        v_id IN courses.id%TYPE
    ) IS

        v_name     courses.name%TYPE;
        v_duration courses.duration%TYPE;
        v_quantity courses.quantity%TYPE;
    BEGIN
        SELECT
            name,
            duration,
            quantity
        INTO
            v_name,
            v_duration,
            v_quantity
        FROM
            courses
        WHERE
            id = v_id;

        dbms_output.put_line('NAME: '
                             || v_name
                             || ' | DURATION: '
                             || v_duration
                             || ' | QUANTITY: '
                             || v_quantity);
--            
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('Cursul cu id-ul: '
                                 || v_id
                                 || ' nu exista in DB');
    END read_course_by_id;

    FUNCTION read_course_by_name (
        v_name courses.name%TYPE
    ) RETURN courses.id%TYPE IS
        v_id courses.id%TYPE;
    BEGIN
        SELECT
            id
        INTO v_id
        FROM
            courses
        WHERE
            name = v_name;

        RETURN ( v_id );
    END read_course_by_name;

    FUNCTION read_course_quantity_by_id (
        v_id courses.id%TYPE
    ) RETURN courses.quantity%TYPE IS
        v_quantity courses.quantity%TYPE;
    BEGIN
        SELECT
            quantity
        INTO v_quantity
        FROM
            courses
        WHERE
            id = v_id;

        RETURN ( v_quantity );
    END read_course_quantity_by_id;

    -- 3. UPDATE COURSES
    PROCEDURE update_course_by_id (
        v_id       IN courses.id%TYPE,
        v_name     courses.name%TYPE,
        v_duration courses.duration%TYPE,
        v_quantity courses.quantity%TYPE
    ) IS
    BEGIN
        UPDATE courses
        SET
            name = v_name,
            duration = v_duration,
            quantity = v_quantity
        WHERE
            id = v_id;

    END update_course_by_id;

    PROCEDURE update_couse_quantity_by_id (
        v_id       IN courses.id%TYPE,
        v_quantity courses.quantity%TYPE
    ) IS
    BEGIN
        UPDATE courses
        SET
            quantity = v_quantity
        WHERE
            id = v_id;

    END update_couse_quantity_by_id;

    -- 4. DELETE COURSES
    PROCEDURE delete_course_by_id (
        v_id IN courses.id%TYPE
    ) IS
    BEGIN
        DELETE FROM courses
        WHERE
            id = v_id;

    END delete_course_by_id;

    PROCEDURE delete_all_courses IS
    BEGIN
        DELETE FROM courses;

    END delete_all_courses;

END crud_courses_pack;
/

CREATE OR REPLACE PACKAGE BODY crud_employee_certificate_pack AS

    PROCEDURE create_employee_certificate (
        v_employees_email   IN employees.email%TYPE,
        v_certificates_name IN certificates.name%TYPE
    ) IS
    BEGIN
        INSERT INTO employee_certificate VALUES (
            crud_employees_pack.read_employee_by_email(v_employees_email),
            crud_certificates_pack.read_certificate_by_name(v_certificates_name)
        );

    END create_employee_certificate;

    PROCEDURE read_all_employee_certificate IS
        v_employee_certificate_record employee_certificate%rowtype;
        CURSOR c IS
        SELECT
            *
        FROM
            employee_certificate
        ORDER BY
            employees_id ASC;

    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO
                v_employee_certificate_record.employees_id,
                v_employee_certificate_record.certificates_id;
            EXIT WHEN c%notfound;
            dbms_output.put_line('EMPLOYEES_ID: '
                                 || v_employee_certificate_record.employees_id
                                 || ' | CERTIFICATES_ID: '
                                 || v_employee_certificate_record.certificates_id);

        END LOOP;

        CLOSE c;
    END read_all_employee_certificate;

    PROCEDURE delete_employee_certificate_by_employee_id_and_certificates_id (
        v_employees_id    IN employee_certificate.employees_id%TYPE,
        v_certificates_id IN employee_certificate.certificates_id%TYPE
    ) IS
    BEGIN
        DELETE FROM employee_certificate
        WHERE
            employees_id = v_employees_id
            AND certificates_id = v_certificates_id;

    END delete_employee_certificate_by_employee_id_and_certificates_id;

    PROCEDURE delete_all_employee_certificate IS
    BEGIN
        DELETE FROM employee_certificate;

    END delete_all_employee_certificate;

END crud_employee_certificate_pack;
/

CREATE OR REPLACE PACKAGE BODY crud_employees_pack AS
    -- 1. CREATE EMPLOYEES
    PROCEDURE create_employee (
        v_email      IN employees.email%TYPE,
        v_password   IN employees.password%TYPE,
        v_department IN employees.department%TYPE
    ) IS
    BEGIN
        INSERT INTO employees (
            email,
            password,
            department
        ) VALUES (
            v_email,
            v_password,
            v_department
        );

    END create_employee;
    
    -- 2. READ EMPLOYEES
    PROCEDURE read_first_specified_employees (
        v_no_employees IN NUMBER
    ) IS
        v_employees_record employees%rowtype;
        CURSOR c IS
        SELECT
            *
        FROM
            employees
        ORDER BY
            id ASC;

    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO
                v_employees_record.id,
                v_employees_record.email,
                v_employees_record.password,
                v_employees_record.department;

            EXIT WHEN c%rowcount > v_no_employees OR c%notfound;
            dbms_output.put_line('ID: '
                                 || v_employees_record.id
                                 || ' | EMAIL: '
                                 || v_employees_record.email
                                 || ' | PASSWORD: '
                                 || v_employees_record.password
                                 || ' | DEPARTMENT: '
                                 || v_employees_record.department);

        END LOOP;

        CLOSE c;
    END read_first_specified_employees;

    PROCEDURE read_all_employees IS
        v_employees_record employees%rowtype;
        CURSOR c IS
        SELECT
            *
        FROM
            employees
        ORDER BY
            id ASC;

    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO
                v_employees_record.id,
                v_employees_record.email,
                v_employees_record.password,
                v_employees_record.department;

            EXIT WHEN c%notfound;
            dbms_output.put_line('ID: '
                                 || v_employees_record.id
                                 || ' | EMAIL: '
                                 || v_employees_record.email
                                 || ' | PASSWORD: '
                                 || v_employees_record.password
                                 || ' | DEPARTMENT: '
                                 || v_employees_record.department);

        END LOOP;

        CLOSE c;
    END read_all_employees;

    PROCEDURE read_employee_by_id (
        v_id IN employees.id%TYPE
    ) IS

        v_email      employees.email%TYPE;
        v_password   employees.password%TYPE;
        v_department employees.department%TYPE;
    BEGIN
        SELECT
            email,
            password,
            department
        INTO
            v_email,
            v_password,
            v_department
        FROM
            employees
        WHERE
            id = v_id;

        dbms_output.put_line('EMAIL: '
                             || v_email
                             || ' | PASSWORD: '
                             || v_password
                             || ' | DEPARTMENT: '
                             || v_department);

    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('Utilizatorul cu id-ul: '
                                 || v_id
                                 || ' nu exista in DB');
    END read_employee_by_id;

    FUNCTION read_employee_by_email (
        v_email employees.email%TYPE
    ) RETURN employees.id%TYPE IS
        v_id employees.id%TYPE;
    BEGIN
        SELECT
            id
        INTO v_id
        FROM
            employees
        WHERE
            email = v_email;

        RETURN ( v_id );
    END read_employee_by_email;
    
    -- 3. UPDATE EMPLOYEES
    PROCEDURE update_employee_by_id (
        v_id         IN employees.id%TYPE,
        v_email      employees.email%TYPE,
        v_password   employees.password%TYPE,
        v_department employees.department%TYPE
    ) IS
    BEGIN
        UPDATE employees
        SET
            email = v_email,
            password = v_password,
            department = v_department
        WHERE
            id = v_id;

    END update_employee_by_id;
    
    -- 4. DELETE EMPLOYEES
    PROCEDURE delete_employee_by_id (
        v_id IN employees.id%TYPE
    ) IS
    BEGIN
        DELETE FROM employees
        WHERE
            id = v_id;

    END delete_employee_by_id;

    PROCEDURE delete_all_employees IS
    BEGIN
        DELETE FROM employees;

    END delete_all_employees;

END crud_employees_pack;
/

CREATE OR REPLACE PACKAGE BODY transaction_pack AS

    e_invalid_certificate EXCEPTION;

    PROCEDURE check_existing_certificate (
        v_employee_id    IN employee_certificate.employees_id%TYPE,
        v_certificate_id IN employee_certificate.certificates_id%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO v_count
        FROM
            employee_certificate
        WHERE
            employees_id = v_employee_id
            AND certificates_id = v_certificate_id;

        IF v_count = 0 THEN
            RAISE e_invalid_certificate;
        END IF;
    END check_existing_certificate;

    PROCEDURE create_assigned_courses (
        v_assigned_date IN assigned_courses.assigned_date%TYPE,
        v_completed     IN assigned_courses.completed%TYPE,
        v_employees_id  IN assigned_courses.employees_id%TYPE,
        v_courses_id    IN assigned_courses.courses_id%TYPE
    ) IS
    BEGIN
        INSERT INTO assigned_courses (
            assigned_date,
            completed,
            employees_id,
            courses_id
        ) VALUES (
            v_assigned_date,
            v_completed,
            v_employees_id,
            v_courses_id
        );

    END create_assigned_courses;

    PROCEDURE transaction_assigned_courses (
        v_employee_email   IN employees.email%TYPE,
        v_course_name      IN courses.name%TYPE,
        v_certificate_name IN certificates.name%TYPE
    ) IS

        v_employee_id    employees.id%TYPE;
        v_course_id      courses.id%TYPE;
        v_certificate_id certificates.id%TYPE;
        v_quantity       courses.quantity%TYPE;
        v_new_quantity   courses.quantity%TYPE;
    BEGIN
        SET TRANSACTION NAME 'assigned_course_to_employee';
        v_employee_id := crud_employees_pack.read_employee_by_email(v_employee_email);
        v_course_id := crud_courses_pack.read_course_by_name(v_course_name);
        v_certificate_id := crud_certificates_pack.read_certificate_by_name(v_certificate_name);
        v_quantity := crud_courses_pack.read_course_quantity_by_id(v_course_id);
        v_new_quantity := v_quantity - 1;
        
        -- Change course quantity in courses table
        crud_courses_pack.update_couse_quantity_by_id(
                                                     v_course_id,
                                                     v_new_quantity
        );
        
        -- Check if the certificate exists in employee_certificate table
        check_existing_certificate(
                                  v_employee_id,
                                  v_certificate_id
        );
        
        -- Create new row in assigned_courses table
        create_assigned_courses(
                               to_date(
                                      sysdate,
                                      'DD/MM/YYYY'
                               ),
                               'F',
                               v_employee_id,
                               v_course_id
        );
        
        -- Delete from the employee_certificate table, the row after id_employee and id_certificate
        crud_employee_certificate_pack.delete_employee_certificate_by_employee_id_and_certificates_id(
                                                                                                     v_employee_id,
                                                                                                     v_certificate_id
        );
        COMMIT;
        dbms_output.put_line('Tranzactie reusita!');
        dbms_output.put_line('');
    EXCEPTION
        WHEN e_invalid_quantity THEN
            dbms_output.put_line('Tranzactie esuata! Cantitate 0');
            dbms_output.put_line('');
            ROLLBACK;
        WHEN e_invalid_certificate THEN
            dbms_output.put_line('Tranzactie esuata! Certificat inexistent');
            dbms_output.put_line('');
            ROLLBACK;
        WHEN OTHERS THEN
            dbms_output.put_line('Tranzactie esuata! Problema nestiuta interceptata');
            dbms_output.put_line('');
            ROLLBACK;
    END transaction_assigned_courses;

    PROCEDURE read_all_assigned_courses IS
        v_assigned_courses_record assigned_courses%rowtype;
        CURSOR c IS
        SELECT
            *
        FROM
            assigned_courses
        ORDER BY
            id ASC;

    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO
                v_assigned_courses_record.id,
                v_assigned_courses_record.assigned_date,
                v_assigned_courses_record.completed,
                v_assigned_courses_record.employees_id,
                v_assigned_courses_record.courses_id;

            EXIT WHEN c%notfound;
            dbms_output.put_line('ID: '
                                 || v_assigned_courses_record.id
                                 || ' | ASSIGNED_DATE: '
                                 || v_assigned_courses_record.assigned_date
                                 || ' | COMPLETED: '
                                 || v_assigned_courses_record.completed
                                 || ' | EMPLOYEES_ID: '
                                 || v_assigned_courses_record.employees_id
                                 || ' | COURSES_ID: '
                                 || v_assigned_courses_record.courses_id);

        END LOOP;

        CLOSE c;
    END read_all_assigned_courses;

END transaction_pack;
/

CREATE SEQUENCE assigned_courses_id_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER assigned_courses_id_TRG 
BEFORE INSERT ON assigned_courses 
FOR EACH ROW 
WHEN (NEW.id IS NULL) 
BEGIN
:new.id := assigned_courses_id_seq.nextval;

end;
/

CREATE SEQUENCE certificates_id_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER certificates_id_TRG 
BEFORE INSERT ON certificates 
FOR EACH ROW 
WHEN (NEW.id IS NULL) 
BEGIN
:new.id := certificates_id_seq.nextval;

end;
/

CREATE SEQUENCE courses_id_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER courses_id_TRG 
BEFORE INSERT ON courses 
FOR EACH ROW 
WHEN (NEW.id IS NULL) 
BEGIN
:new.id := courses_id_seq.nextval;

end;
/

CREATE SEQUENCE employees_id_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER employees_id_TRG 
BEFORE INSERT ON employees 
FOR EACH ROW 
WHEN (NEW.id IS NULL) 
BEGIN
:new.id := employees_id_seq.nextval;

end;
/



-- Oracle SQL Developer Data Modeler Summary Report: 
-- 
-- CREATE TABLE                             5
-- CREATE INDEX                             0
-- ALTER TABLE                             11
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           5
-- CREATE PACKAGE BODY                      5
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           5
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          4
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
