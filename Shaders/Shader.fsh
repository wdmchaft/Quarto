//
//  Shader.fsh
//  Quarto
//
//  Created by Jonathan Nobels on 10-09-16.
//  Copyright Barn*Star Studios 2010. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
