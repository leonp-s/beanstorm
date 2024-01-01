#pragma once

#include "view_delegate.h"

class BeanstormBLE final : public ViewDelegate
{
public:
    ~BeanstormBLE () override = default;
    void Setup () override;
    void ModelDidUpdate (const Model & model) override;
};
