package b

import a.*

main() {
    r.width = 8 // OK: public 'width' can be accessed here
    r.height = 24 // Error, no modifier 'height' can't be accessed here
    r.area = 30 // Error, private 'area' can't be accessed here
}
