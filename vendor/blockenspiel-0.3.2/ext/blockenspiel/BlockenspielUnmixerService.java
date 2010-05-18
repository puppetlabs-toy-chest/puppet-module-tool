/*
  -----------------------------------------------------------------------------
  
  Blockenspiel unmixer (JRuby implementation)
  
  -----------------------------------------------------------------------------
  Copyright 2008-2009 Daniel Azuma
  
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  * Neither the name of the copyright holder, nor the names of any other
    contributors to this software, may be used to endorse or promote products
    derived from this software without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE.
  -----------------------------------------------------------------------------
*/


/*
  This implementation based on Mixology,
  written by Patrick Farley, anonymous z, Dan Manges, and Clint Bishop.
  http://rubyforge.org/projects/mixology
  http://github.com/dan-manges/mixology/tree/master
  
  It has been stripped down and modified for JRuby 1.2 compatibility.
*/

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
 
import org.jruby.Ruby;
import org.jruby.RubyArray;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.anno.JRubyMethod;
import org.jruby.IncludedModuleWrapper;
import org.jruby.runtime.Block;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.exceptions.RaiseException;
import org.jruby.runtime.load.BasicLibraryService;


public class BlockenspielUnmixerService implements BasicLibraryService
{
    
    public boolean basicLoad(final Ruby runtime) throws IOException
    {
        RubyModule blockenspielModule = runtime.getOrCreateModule("Blockenspiel");
        RubyModule unmixerModule = runtime.defineModuleUnder("Unmixer", blockenspielModule);
        unmixerModule.getSingletonClass().defineAnnotatedMethods(BlockenspielUnmixerService.class);
        return true;
    }
    
    
    @JRubyMethod(name = "unmix", required = 2)
    public synchronized static IRubyObject unmix(IRubyObject self, IRubyObject receiver, IRubyObject module, Block block)
        throws NoSuchMethodException, IllegalAccessException, InvocationTargetException
    {
        RubyModule actualModule = (RubyModule)module;
        RubyClass klass = receiver.getMetaClass();
        while (klass != receiver.getMetaClass().getRealClass())
        {
            RubyClass superClass = klass.getSuperClass();
            if (superClass != null && superClass.getNonIncludedClass() == actualModule)
            {
                if (actualModule.getSuperClass() != null &&
                    actualModule.getSuperClass() instanceof IncludedModuleWrapper)
                {
                    removeNestedModule(superClass, actualModule);
                }
                setSuperClass(klass, superClass.getSuperClass());
                invalidateCacheDescendants(klass);
            }
            klass = superClass;
        }
        return receiver;
    }
    
    
    protected synchronized static void removeNestedModule(RubyClass klass, RubyModule module) 
        throws NoSuchMethodException, IllegalAccessException, InvocationTargetException
    {
        if ((klass.getSuperClass() instanceof IncludedModuleWrapper) &&
            ((IncludedModuleWrapper)klass.getSuperClass()).getNonIncludedClass() ==
            ((IncludedModuleWrapper)module.getSuperClass()).getNonIncludedClass())
        {
            if (module.getSuperClass().getSuperClass() != null &&
                module.getSuperClass() instanceof IncludedModuleWrapper)
            {
                removeNestedModule(klass.getSuperClass(), module.getSuperClass());
            }
            setSuperClass(klass, klass.getSuperClass().getSuperClass());
        }
    }
    
    
    protected synchronized static void setSuperClass(RubyModule klass, RubyModule superClass)
        throws NoSuchMethodException, IllegalAccessException, InvocationTargetException
    {
        Method method = RubyModule.class.getDeclaredMethod("setSuperClass",
                                                           new Class[] {RubyClass.class} );
        method.setAccessible(true);
        Object[] superClassArg = new Object[] { superClass };
        method.invoke(klass, superClassArg);
    }
    
    
    protected synchronized static void invalidateCacheDescendants(RubyModule klass)
        throws NoSuchMethodException, IllegalAccessException, InvocationTargetException
    {
        Method method = RubyModule.class.getDeclaredMethod("invalidateCacheDescendants", new Class[0]);
        method.setAccessible(true);
        method.invoke(klass, new Object[0]);
    }
    
}
 