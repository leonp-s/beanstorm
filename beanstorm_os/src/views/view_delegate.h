#pragma once

#include <functional>
#include "model.h"

class ViewDelegate
{
public:
    virtual ~ViewDelegate () = default;
    virtual void Setup () = 0;
    virtual void ModelDidUpdate (const Model & model) = 0;

    std::function<void  ()> OnProfileDidLoad;
};
