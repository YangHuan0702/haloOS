struct spinlock {
  uint locked;     

  char *name;

  struct cpu *cpu; 
};