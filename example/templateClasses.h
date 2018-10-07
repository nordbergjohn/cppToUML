
template<typename T>
class TemplateClassT {
  /*
   int m_notIncluded; <- Part of multiline comment, not included in UML
   */
  private:
    T m_var;
};

// Template class with multiline inheritance
template<typename K, typename L, class M>
struct ChildT : public TemplateClassT<T>,
  protected Parent
{
  // Multiline function, should be included in UML
  ExampleNameSpace::Type function(K k,
      L l,
      M m);
  //int dump(); <-  Not included in UML as this row is a comment
  protected:
    K m_k;
    L m_l;
    M m_m;
  private:
  // Multiline variable, should be included in UML
  ExampleNameSpace::Type
    m_longVariableName;
};

