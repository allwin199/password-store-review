# The Review Process

1. Initial Review
    1. Scoping
        - [ ]  Run Solidity Metrics to get “nsloc”
        - [ ]  Rekt Test
            
            [Can you pass the Rekt test?](https://blog.trailofbits.com/2023/08/14/can-you-pass-the-rekt-test/)
            
        - [ ]  Audit Readiness Checklist
        
            [Audit Readiness Checklist](https://github.com/nascentxyz/simple-security-toolkit/blob/main/audit-readiness-checklist.md)
        
    2. Reconnaissance
        - [ ]  Read the Docs
        - [ ]  Understand the code base in high level
        - [ ]  Run Test Coverage
  
    3. Vulnerability identification
        - [ ]  Manual Walkthrough (Tincho Method)
        - [ ]  Checklist Method (Hans Method)
        - [ ]  Utilize Solodit
        - [ ]  Stateful Fuzzing
        - [ ]  Run Slither
        - [ ]  Run Aderyn
        - [ ]  Run 4analyzer
  
    4. Reporting
        - [ ]  Write Detailed Report with Poc and Mitigation
  
2. Protocol fixes
    1. Fixes issues
    2. Retests and adds tests
   
3. Mitigation Review
    1. (Repeat #1)