function addTaxonFilterRow() {
    // User has clicked to add another taxon row
    var lastTaxonFilterRow = $('.taxon-filter-row').last();
    // Create an element
    var el = lastTaxonFilterRow.clone(true);
    lastTaxonFilterRow.after(el)
}

function addTraitFilterRow() {
    // User has clicked to add another trait row
    var lastTraitFilterRow = $('.trait-filter-row').last();
    // Create an element
    var el = lastTraitFilterRow.clone(true);
    lastTraitFilterRow.after(el)
}

function addButtonHandlers() {
    $('.add_taxon').bind('click', function() {
        addTaxonFilterRow();
    });
    $('.remove_taxon').bind('click', function() {
        if ($(".taxon-filter-row").length > 1) {
            // Don't remove the only row
            $(this).parents(".taxon-filter-row").remove();
        }
    });
    $('.add_trait').bind('click',function() {
        addTraitFilterRow();
    });
    $('.remove_trait').bind('click', function() {
        if ($(".trait-filter-row").length > 1) {
            // Don't remove the only row
            $(this).parents(".trait-filter-row").remove();
        }
    });
}

function updateOrderList(higherGroupElement, orderList) {
    var orderElement = $(higherGroupElement).siblings(".order");
    // remove all options from the element
    orderElement.find('option').remove();
    orderElement.append($('<option></option>'));
    for(var order in orderList) {
        var obj = orderList[order];
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        orderElement.append(optionElement);
    }
    // Also clear the lower levels
    $(orderElement).siblings(".family").find('option').remove();
    $(orderElement).siblings(".genus").find('option').remove();
}

function updateFamilyList(orderElement, familyList) {
    var familyElement = $(orderElement).siblings(".family");
    // remove all options from the element
    familyElement.find('option').remove();
    familyElement.append($('<option></option>'));

    for(var family in familyList) {
        var obj = familyList[family];
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        familyElement.append(optionElement);
    }
    $(familyElement).siblings(".genus").find('option').remove();
}

function updateGenusList(familyElement, genusList) {
    // find the genus select element
    var genusElement = $(familyElement).siblings(".genus");
    // remove all options from the genus element
    genusElement.find('option').remove();
    genusElement.append($('<option></option>'));
    for(var genus in genusList) {
        var obj = genusList[genus];
        console.log("name: " + obj.name + " id: " + obj.id);
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        genusElement.append(optionElement);
    }
}

function updateTraitNames(traitGroupElement, traitList) {
    // find the trait names select element
    var traitElement = $(traitGroupElement).siblings(".trait_name");
    // remove all options from the select
    traitElement.find('option').remove();
    for(var trait in traitList) {
        var obj = traitList[trait].chr;
        console.log("name: " + obj.name + " id: " + obj.id + " continuous: " + obj.is_continuous);
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitElement.append(optionElement);
    }
}

function updateTraitValues(traitElement, valueList) {
    // find the trait values select element
    var traitValuesElement = $(traitElement).siblings(".trait_values");
    // remove all options from the select
    traitValuesElement.find('option').remove();
    for(var traitValue in valueList) {
        var obj = valueList[traitValue];
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitValuesElement.append(optionElement);
    }
}

function higherGroupChanged(higherGroupElement, higherGroupId) {
    $(higherGroupElement).siblings(".order").find('option').remove();
    $.ajax({
        url: "/search/list_order.json",
        data: { htg_id: higherGroupId}
    }).done(function(data, textStatus, jqXHR) { updateOrderList(higherGroupElement, data)});
}

function orderChanged(orderElement, orderId) {
    $(orderElement).siblings(".family").find('option').remove();
    $.ajax({
        url: "/search/list_family.json",
        data: { order_id: orderId}
    }).done(function(data, textStatus, jqXHR) { updateFamilyList(orderElement, data)});
}

function familyChanged(familyElement, familyId) {
    $(familyElement).siblings(".genus").find('option').remove();
    $.ajax({
        url: "/search/list_genus.json",
        data: { family_id: familyId }
    }).done(function(data, textStatus, jqXHR) { updateGenusList(familyElement, data)});
}

function traitGroupChanged(traitGroupElement, traitGroupId) {
    $(traitGroupElement).siblings(".trait_name").find('option').remove();
    $.ajax({
        url: "/search/list_traits.json",
        data: { trait_group_id: traitGroupId }
    }).done(function(data, textStatus, jqXHR) { updateTraitNames(traitGroupElement, data)});
}

// when a trait is changed, update the possible values
function traitChanged(traitElement, traitId) {
    $(traitElement).siblings(".trait_values").find('option').remove();
    $.ajax({
        url: "/search/list_trait_values.js",
        data: { trait_id: traitId }
    }).done(function(data, textstatus, jqXHR) { updateTraitValues(traitElement, data)});
}

function addSelectionChangeListeners() {
    // taxonomy
    $('select.htg').change(function() {
        higherGroupChanged(this,this.value);
    });
    $('select.order').change(function() {
        orderChanged(this,this.value);
    });
    $('select.family').change(function() {
        familyChanged(this,this.value);
    });
    // trait
    $('select.trait_group').change(function() {
        traitGroupChanged(this,this.value);
    });
    $('select.trait_name').change(function() {
        traitChanged(this,this.value);
    });
}