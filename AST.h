/* nodes in the abstract syntax tree */ 

struct ast {
   int nodetype;
   struct ast *l;
   struct ast *r;
};

struct numval { 
   int nodetype;
   double number; 
};

/* build an AST */
  struct ast *newast(int nodetype, struct ast *l, struct ast *r); 
  struct ast *newnum(double d);

/* evaluate an AST */ 
  double eval(struct ast *);

/* delete and free an AST */ 
  void treefree(struct ast *);

struct ast * newast(int nodetype, struct ast *l, struct ast *r) {
  struct ast *a = malloc(sizeof(struct ast));
  if(!a) {
    yyerror("out of space");
    exit(0); 
  }
  //printf("NEW AST||||| ");
  a->nodetype = nodetype; a->l = l;
  a->r = r;

  //printf("NEW AST %s ..|| ", a);

  return a;
}

struct ast * newnum(double d) {
  struct numval *a = malloc(sizeof(struct numval));
  if(!a) {
    yyerror("out of space");
    exit(0); 
  }
  a->nodetype = 'K';
  a->number = d;
  //printf("NEW NUM: %s .. %lf ..|| ", a, a->number);

  return (struct ast *)a;
}

double eval(struct ast *a) {
  double v;
  //printf("EVAL||||| ");
  switch(a->nodetype) {
    case 'K': v = ((struct numval *)a)->number; 
	break;
    case '+': v = eval(a->l) + eval(a->r);  
	break;
    case '-': v = eval(a->l) - eval(a->r);
	break;
    case '*': v = eval(a->l) * eval(a->r);
	break;
    case '/': v = eval(a->l) / eval(a->r); break;
    case '|': v = eval(a->l); if(v < 0) v = -v; 
	break;
    case 'M': v = -eval(a->l); 
	break;
    default: printf("internal error: bad node %c\n", a->nodetype); 
   }
  return v;
}


void treefree(struct ast *a) {
  switch(a->nodetype) {
  /* two subtrees */ case '+':
  case '-':
  case '*':
  case '/':
    treefree(a->r);
  /* one subtree */
  case '|':
  case 'M':
    treefree(a->l);

  /* no subtree */
  case 'K':
    free(a);
    break;
  default: printf("internal error: free bad node %c\n", a->nodetype);
  } 
}



/*NEW

struct ast * newcmp(int cmptype, struct ast *l, struct ast *r){
  struct ast *a = malloc(sizeof(struct ast));
  if(!a) {
    yyerror("out of space");
    exit(0); 
  }
  a->nodetype = '0' + cmptype; a->l = l;
  a->r = r;
  return a;
}

struct ast * newfunc(int functype, struct ast *l) {
  struct fncall *a = malloc(sizeof(struct fncall));
  if(!a) {
    yyerror("out of space");
    exit(0); 
  }
  a->nodetype = 'F';
  a->l = l;
  a->functype = functype; 
  return (struct ast *)a;
}


struct ast * newcall(struct symbol *s, struct ast *l) {
  struct ufncall *a = malloc(sizeof(struct ufncall));
  if(!a) {
    yyerror("out of space");
    exit(0); 
  }
  a->nodetype = 'C';
  a->l = l;
  a->s = s;
  return (struct ast *)a;
}

struct ast * newref(struct symbol *s) {
  struct symref *a = malloc(sizeof(struct symref));
  if(!a) {
    yyerror("out of space");
    exit(0); 
  }
  a->nodetype = 'N';
  a->s = s;
  return (struct ast *)a;
}

struct ast * newasgn(struct symbol *s, struct ast *v) {
  struct symasgn *a = malloc(sizeof(struct symasgn));
  if(!a) {
    yyerror("out of space");
    exit(0); 
  }
  a->nodetype = '=';
  a->s = s;
  a->v = v;
  return (struct ast *)a;
}

struct ast * newflow(int nodetype, struct ast *cond, struct ast *tl, struct ast *el) {
  struct flow *a = malloc(sizeof(struct flow));
  if(!a) {
    yyerror("out of space");
    exit(0); 
  }
  a->nodetype = nodetype; a->cond = cond;
  a->tl = tl;
  a->el = el;
  return (struct ast *)a; 
}

struct symlist * newsymlist(struct symbol *sym, struct symlist *next) {
  struct symlist *sl = malloc(sizeof(struct symlist));
  if(!sl) {
    yyerror("out of space");
    exit(0); 
  }
  sl->sym = sym; sl->next = next; return sl;
}

// free a list of symbols
void symlistfree(struct symlist *sl) {
  struct symlist *nsl;
  while(sl) {
    nsl = sl->next; free(sl);
    sl = nsl;
  } 
}


NEW*/

