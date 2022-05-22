SET SERVEROUTPUT ON

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

CREATE OR REPLACE PACKAGE BODY crud_employees_pack AS
    -- 1. CREATE EMPLOYEES
    PROCEDURE create_employee (
        v_email IN employees.email%TYPE,
        v_password IN employees.password%TYPE,
        v_department IN employees.department%TYPE
    ) 
    IS
    BEGIN
      INSERT INTO employees(email, password, department) VALUES (v_email, v_password, v_department);
    END create_employee;
    
    -- 2. READ EMPLOYEES
    PROCEDURE read_first_specified_employees (v_no_employees IN NUMBER) 
    IS
        v_employees_record employees%ROWTYPE;
        CURSOR c IS SELECT * FROM employees ORDER BY id ASC;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO v_employees_record.id, v_employees_record.email, v_employees_record.password, v_employees_record.department;
            EXIT WHEN c%ROWCOUNT > v_no_employees OR c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_employees_record.id || ' | EMAIL: ' || v_employees_record.email
            || ' | PASSWORD: ' || v_employees_record.password 
            || ' | DEPARTMENT: ' || v_employees_record.department);
        END LOOP;
        CLOSE c;
    END read_first_specified_employees;
    
    PROCEDURE read_all_employees
    IS
        v_employees_record employees%ROWTYPE;
        CURSOR c IS SELECT * FROM employees ORDER BY id ASC;
    BEGIN
        OPEN c;
        LOOP
            FETCH c INTO v_employees_record.id, v_employees_record.email, v_employees_record.password, v_employees_record.department;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('ID: ' || v_employees_record.id || ' | EMAIL: ' || v_employees_record.email
            || ' | PASSWORD: ' || v_employees_record.password 
            || ' | DEPARTMENT: ' || v_employees_record.department);
        END LOOP;
        CLOSE c;
    END read_all_employees;
    
    PROCEDURE read_employee_by_id (v_id IN employees.id%TYPE)
    IS
        v_email employees.email%TYPE;
        v_password employees.password%TYPE;
        v_department employees.department%TYPE;
    BEGIN
        SELECT email, password, department INTO v_email, v_password, v_department FROM employees WHERE id = v_id;
            DBMS_OUTPUT.PUT_LINE('EMAIL: ' || v_email
            || ' | PASSWORD: ' || v_password 
            || ' | DEPARTMENT: ' || v_department);
            
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Utilizatorul cu id-ul: ' || v_id || ' nu exista in DB');
    END read_employee_by_id;
    
    FUNCTION read_employee_by_email (v_email employees.email%TYPE) RETURN employees.id%TYPE
    IS
        v_id employees.id%TYPE;
    BEGIN
        SELECT id INTO v_id FROM employees WHERE email = v_email;
        RETURN (v_id);
    END read_employee_by_email;
    
    -- 3. UPDATE EMPLOYEES
    PROCEDURE update_employee_by_id (
        v_id IN employees.id%TYPE,
        v_email employees.email%TYPE,
        v_password employees.password%TYPE,
        v_department employees.department%TYPE    
    )
    IS
    BEGIN
        UPDATE employees SET email = v_email, password = v_password, department = v_department WHERE id = v_id;
    END update_employee_by_id;
    
    -- 4. DELETE EMPLOYEES
    PROCEDURE delete_employee_by_id (v_id IN employees.id%TYPE)
    IS
    BEGIN
        DELETE FROM employees WHERE id = v_id;
    END delete_employee_by_id;
    
    PROCEDURE delete_all_employees
    IS
    BEGIN
        DELETE FROM employees;
    END delete_all_employees;
END crud_employees_pack;