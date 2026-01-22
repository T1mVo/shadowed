#import "test.typ": test-gradients, page-layout

#set page(..page-layout)

#for test-gradient in test-gradients [
  #page[
    #block(width: 100%, height: 100%, fill: test-gradient)
  ]
]
