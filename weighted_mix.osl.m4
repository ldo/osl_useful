dnl+
dnl This file is a template for generating Open Shading Language shaders that
dnl do weighted mixing of their inputs. Each input is associated with a scalar
dnl weight that governs its relative contribution to the output. The actual
dnl values of the weights don’t matter, only their relative magnitudes.
dnl
dnl Use this template as follows:
dnl
dnl     m4 -Dname=name -Dtype=type -Dinputs=inputs [-Dweightout] weighted_mix.osl.m4
dnl
dnl where “name” is the name to give to the shader, “type” is the type
dnl of the inputs and outputs, “inputs” is the positive integer number of
dnl inputs that the shader will mix, and -Dweightout indicates that you
dnl also want an output for the summed input weights, for chaining multiple
dnl mixers together.
dnl
dnl “type” can be any type that OSL allows the requisite arithmetic operations on,
dnl e.g. “float”, “color”, “point”. It can also be “closure color” to create
dnl a mix shader.
dnl
dnl Copyright 2016 by Lawrence D'Oliveiro <ldo@geek-central.gen.nz>.
dnl Licensed under CC-BY <http://creativecommons.org/licenses/by/4.0/>.
dnl-
ifdef(`name', `', `errprint(`forgot to define name for shader
')m4exit(1)')dnl
ifdef(`type', `', `errprint(`forgot to define type for shader
')m4exit(1)')dnl
ifdef(`inputs', `', `errprint(`forgot to define number of inputs
')m4exit(1)')dnl
define(`is_closure', eval(regexp(type, `closure') > -1))dnl
define(`default_type',
    `ifelse(is_closure, 1, `', type)'dnl
)dnl
dnl
define(`def_inputs', `ifelse($1, 1, `', `def_inputs(eval($1 - 1))')dnl
    type Input$1 = default_type`'(0),
    float Weight$1 = 0,
')dnl
define(`add_inputs', `ifelse($1, 1, `', `add_inputs(eval($1 - 1)) + ')dnl
Input$1 * Weight$1')dnl
define(`add_weights', `ifelse($1, 1, `', `add_weights(eval($1 - 1)) + ')dnl
Weight$1')dnl
dnl
shader name
  (
def_inputs(inputs)dnl
    output type Output = default_type`'(0)`'dnl
ifdef(`weightout', `,
    output float Weight = 0', `')
  )
  {
    dnl
ifdef(`weightout', `', `float ')dnl
Weight = add_weights(inputs);
    Output = (add_inputs(inputs)) dnl
ifelse(is_closure, 1, `* (1 / Weight)',
`/ Weight');
dnl OSL doesn’t allow division of closure by anything, only multiplication
  } /*name*/
