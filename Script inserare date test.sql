BEGIN
    -- ADD EMPLOYEES
    crud_employees_pack.create_employee('silviu.butnaru@student.tuiasi.ro', 'silviu', 'VNI');
    crud_employees_pack.create_employee('alberto-ionut.toscariu@student.tuiasi.ro', 'alberto-ionut', 'VNI');
    crud_employees_pack.create_employee('vlad.paraschiv@student.tuiasi.ro', 'vlad', 'HMI');
END;    
/

BEGIN
    -- ADD CERTIFICATES
    crud_certificates_pack.create_certificate('Solution Architect', TO_DATE('11/05/2020', 'DD/MM/YYYY'), TO_DATE('11/05/2025', 'DD/MM/YYYY'));
    crud_certificates_pack.create_certificate('DevOps Engineer', TO_DATE('09/07/2021', 'DD/MM/YYYY'), TO_DATE('09/07/2024', 'DD/MM/YYYY'));
    crud_certificates_pack.create_certificate('Cloud Partitioner', TO_DATE('22/04/2022', 'DD/MM/YYYY'), TO_DATE('22/04/2023', 'DD/MM/YYYY'));
END;
/

BEGIN   
    -- ADD EMPLOYEE_CERTIFICATE
    crud_employee_certificate_pack.create_employee_certificate('silviu.butnaru@student.tuiasi.ro', 'Solution Architect');
    crud_employee_certificate_pack.create_employee_certificate('silviu.butnaru@student.tuiasi.ro', 'DevOps Engineer');
    crud_employee_certificate_pack.create_employee_certificate('silviu.butnaru@student.tuiasi.ro', 'Cloud Partitioner');
    crud_employee_certificate_pack.create_employee_certificate('alberto-ionut.toscariu@student.tuiasi.ro', 'DevOps Engineer');
    crud_employee_certificate_pack.create_employee_certificate('alberto-ionut.toscariu@student.tuiasi.ro', 'Cloud Partitioner');
    crud_employee_certificate_pack.create_employee_certificate('vlad.paraschiv@student.tuiasi.ro', 'Solution Architect');
END;
/

BEGIN
    -- ADD COURSES
    crud_courses_pack.create_course('Object Oriented', 15, 2);
    crud_courses_pack.create_course('Software Analysis and Design', 40, 3);
    crud_courses_pack.create_course('Tests and Maintenance', 40, 1);
	crud_courses_pack.create_course('Data Structures and Algorithms', 80, 1);
END;
/
COMMIT;