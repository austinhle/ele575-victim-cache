// Modified by Princeton University on June 9th, 2015
/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: PlusArg.h
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
// Description:  A class for storing plusarg data.
//
//------------------------------------------------------------------------------

#ifndef PLUSARG_H
#define PLUSARG_H

class PlusArg
{
public:
  char *name;
  int value;
  char *str;
  int owner;

  PlusArg(char *n, int v, int o) {
    name = new char[strlen(n)];
    strcpy(name, n);
    value = v;
    str = NULL;
    owner = o;
  }
  ~PlusArg() { delete name; if (str) delete str; }
};

#endif // PLUSARG_H
