// Modified by Princeton University on June 9th, 2015
/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: ListTree.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
//------------------------------------------------------------------------------
//
// ListTree.h
//
//
// DESCRIPTION: Desribes a tree-of-lists storage structure.
//
//------------------------------------------------------------------------------

#include "DoubleLinkedList.h"

#ifndef LISTTREE_H
#define LISTTREE_H

class ListTree {
private:
  DoubleLinkedList *top;
  int depth;

  int doInsertion(DoubleLinkedList *, unsigned short *, void *, int);
  int doRemoval(DoubleLinkedList *, unsigned short *, int);
  char *doPrint(DoubleLinkedList *, int);

public:
  ListTree(int);
  ~ListTree();
  int Insert(unsigned short *, void *);
  int Remove(unsigned short *);
  void *Find(unsigned short *);
  int Empty();
  char *Print();
};

#endif // LISTTREE_H
