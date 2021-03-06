/*
    File: evaluator.h
*/

/*
Copyright (c) 2014, Christian E. Schafmeister
 
CLASP is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.
 
See directory 'clasp/licenses' for full details.
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
/* -^- */
#ifndef evaluator_H
#define evaluator_H

#include <clasp/core/foundation.h>
#include <clasp/core/ql.h>
#include <clasp/core/evaluator.fwd.h>
#include <clasp/core/executables.h>
#include <clasp/core/activationFrame.h>

namespace cl {
extern core::Symbol_sp _sym_findClass;
extern core::Symbol_sp _sym_undefinedFunction;
};
namespace kw {
extern core::Symbol_sp _sym_name;
};

namespace core {

T_sp af_interpreter_lookup_variable(Symbol_sp sym, T_sp env);
T_sp af_interpreter_lookup_function(Symbol_sp sym, T_sp env);
T_sp af_interpreter_lookup_macro(Symbol_sp sym, T_sp env);
T_sp core__lookup_symbol_macro(Symbol_sp sym, T_sp env);

 /*! Evaluate within env.
          See ecl/src/c/compiler.d:eval-with-env */
T_mv core__eval_with_env_default(T_sp form, T_sp env);

namespace eval {


extern List_sp evaluateList(List_sp args, T_sp environment);
extern T_mv evaluateListReturnLast(List_sp args, T_sp environment);

extern T_mv sp_progn(List_sp code, T_sp env);
extern T_mv sp_setq(List_sp args, T_sp environment);

extern void defineSpecialOperatorsAndMacros(Package_sp pkg);

T_sp lookupFunction(T_sp functionDesignator, T_sp env);

/*! Evaluate a list of expressions (args) into an ActivationFrame that has
	  enough storage to accept each of the objects that is generated by the list of args */
extern void evaluateIntoActivationFrame(ActivationFrame_sp af, List_sp args, T_sp environment);

/*! See the CLHS for "apply" - all arguments are in args 
  (functionDesignator) can be a Symbol or an Function
*/

extern T_mv applyClosureToActivationFrame(gctools::tagged_pointer<Closure> closureP, ActivationFrame_sp af);

extern T_mv applyToActivationFrame(T_sp functionDesignator, ActivationFrame_sp af);

/*! I want a variadic template function that does APPLY.  C++ variadic template parameter packs
	  must be the last arguments of a function.   APPLY has as its last arguments argsPLUS.
	  So we move argsPLUS up to be the second argument (after the function designator) and list
	  the variadic arguments following it */
template <class... Args>
inline T_mv applyLastArgsPLUSFirst(T_sp fn, List_sp argsPLUS, Args... args) {
  T_sp tfunc = lookupFunction(fn, _Nil<T_O>());
  if (tfunc.nilp())
    ERROR_UNDEFINED_FUNCTION(fn);
  Function_sp func = gc::As<Function_sp>(tfunc);
  int numArgsPassed = sizeof...(Args);
  int numArgsPlus = cl__length(argsPLUS);
  int nargs = numArgsPassed + numArgsPlus;
  ValueFrame_sp frob(ValueFrame_O::create_fill_numExtraArgs(numArgsPlus, _Nil<ActivationFrame_O>(), args...));
  List_sp cur = argsPLUS;
  for (int i = numArgsPassed; i < nargs; ++i) {
    frob->operator[](i) = oCar(cur);
    cur = oCdr(cur);
  }
  gctools::tagged_pointer<Closure> closureP = func->closure;
  ASSERTF(closureP, BF("In applyToActivationFrame the closure for %s is NULL") % _rep_(fn));
  return applyClosureToActivationFrame(closureP, frob);
}

inline T_mv apply_consume_VaList(Function_sp func, VaList_sp args) {
  gctools::tagged_pointer<Closure> ft = func->closure;
  // Either assume that the VaList_sp is not at the start or ensure that it always is
  // Here I'm assuming that it is not always at the start.   To do it the other way
  // change cl__apply
  core::T_O *arg0;
  core::T_O *arg1;
  core::T_O *arg2;
  VaList_S &valist_s = *args;
  LCC_VA_LIST_INDEXED_ARG(arg0, valist_s, 0);
  LCC_VA_LIST_INDEXED_ARG(arg1, valist_s, 1);
  LCC_VA_LIST_INDEXED_ARG(arg2, valist_s, 2);
  gc::return_type res = (*ft).invoke_va_list(NULL,
                                             args.raw_(),
                                             LCC_VA_LIST_NUMBER_OF_ARGUMENTS(args),
                                             arg0,  // LCC_VA_LIST_REGISTER_ARG0(args),
                                             arg1,  // LCC_VA_LIST_REGISTER_ARG1(args),
                                             arg2); //LCC_VA_LIST_REGISTER_ARG2(args) );
  return res;
}
inline LCC_RETURN funcall(T_sp fn) {
  /* If the following assertion fails then the funcall functions in this header
     need to be made consistent with lispCallingConvention.h */
  ASSERT(3 == LCC_ARGS_IN_REGISTERS);
  T_sp tfunc = lookupFunction(fn, _Nil<T_O>());
  if (tfunc.nilp())
    ERROR_UNDEFINED_FUNCTION(fn);
  Function_sp func = gc::As<Function_sp>(tfunc);
  gctools::tagged_pointer<Closure> ft = func->closure;
  return (*ft)(LCC_PASS_ARGS0_ELLIPSIS());
}

template <class ARG0>
inline LCC_RETURN funcall(T_sp fn, ARG0 arg0) {
  /* If the following assertion fails then the funcall functions in this header
     need to be made consistent with lispCallingConvention.h */
  ASSERT(3 == LCC_ARGS_IN_REGISTERS);
  T_sp tfunc = lookupFunction(fn, _Nil<T_O>());
  if (tfunc.nilp())
    ERROR_UNDEFINED_FUNCTION(fn);
  Function_sp func = gc::As<Function_sp>(tfunc);
  gctools::tagged_pointer<Closure> ft = func->closure;
  return (*ft)(LCC_PASS_ARGS1_ELLIPSIS(arg0.raw_()));
}

template <class ARG0, class ARG1>
inline LCC_RETURN funcall(T_sp fn, ARG0 arg0, ARG1 arg1) {
  /* If the following assertion fails then the funcall functions in this header
     need to be made consistent with lispCallingConvention.h */
  ASSERT(3 == LCC_ARGS_IN_REGISTERS);
  T_sp tfunc = lookupFunction(fn, _Nil<T_O>());
  //      printf("%s:%d funcall fn=%s arg0=%s arg1=%s\n", __FILE__, __LINE__, _rep_(fn).c_str(), _rep_(arg0).c_str(), _rep_(arg1).c_str() );
  if (tfunc.raw_() == NULL || tfunc.nilp()) {
    // While booting, cl::_sym_findClass will apply'd before
    // it is bound to a symbol
    if (fn == cl::_sym_findClass) {
      Class_mv cl = cl__find_class(gc::As<Symbol_sp>(arg0), false, _Nil<T_O>());
      T_sp res = cl;
      return Values(res);
    }
    ERROR_UNDEFINED_FUNCTION(fn);
  }
  Function_sp func = tfunc.asOrNull<Function_O>();
  ASSERT(func);
  gctools::tagged_pointer<Closure> ft = func->closure;
  return (*ft)(LCC_PASS_ARGS2_ELLIPSIS(arg0.raw_(), arg1.raw_()));
}

template <class ARG0, class ARG1, class ARG2>
inline LCC_RETURN funcall(T_sp fn, ARG0 arg0, ARG1 arg1, ARG2 arg2) {
  /* If the following assertion fails then the funcall functions in this header
     need to be made consistent with lispCallingConvention.h */
  ASSERT(3 == LCC_ARGS_IN_REGISTERS);
  T_sp tfunc = lookupFunction(fn, _Nil<T_O>());
  if (tfunc.nilp())
    ERROR_UNDEFINED_FUNCTION(fn);
  Function_sp func = gc::As<Function_sp>(tfunc);
  gctools::tagged_pointer<Closure> ft = func->closure;
  return (*ft)(LCC_PASS_ARGS3_ELLIPSIS(LCC_FROM_SMART_PTR(arg0), LCC_FROM_SMART_PTR(arg1), LCC_FROM_SMART_PTR(arg2)));
}

// Do I need a variadic funcall???
template <class ARG0, class ARG1, class ARG2, class... ARGS>
inline LCC_RETURN funcall(T_sp fn, ARG0 arg0, ARG1 arg1, ARG2 arg2, ARGS &&... args) {
  /* If the following assertion fails then the funcall functions in this header
     need to be made consistent with lispCallingConvention.h */
  ASSERT(3 == LCC_ARGS_IN_REGISTERS);
  T_sp tfunc = lookupFunction(fn, _Nil<T_O>());
  if (tfunc.nilp())
    ERROR_UNDEFINED_FUNCTION(fn);
  Function_sp func = gc::As<Function_sp>(tfunc);
  gctools::tagged_pointer<Closure> ft = func->closure;
  size_t vnargs = sizeof...(ARGS);
  size_t nargs = vnargs + LCC_FIXED_NUM;
  return (*ft)(NULL, NULL, nargs, LCC_FROM_SMART_PTR(arg0), LCC_FROM_SMART_PTR(arg1), LCC_FROM_SMART_PTR(arg2), std::forward<ARGS>(args).raw_()...);
}
};
};

#endif
